extends "res://Scripts/Model/Screen.gd"

class BattleSelection:
	var sprite
	var battle_object

	func reset():
		sprite = null
		battle_object = null

# imports
var Planet = preload("res://Scripts/Model/Planet.gd")
var Ship = preload("res://Scripts/Model/Ship.gd")
var StarLane = preload("res://Scripts/Model/StarLane.gd")
var PlanetModule = preload("res://Scripts/Model/OrbitalTile.gd")
var ShipModule = preload("res://Scripts/Model/ShipModuleTile.gd")

var ShipController = preload("res://Scripts/Controller/ShipController.gd")
var StarSystemController = preload("res://Scripts/Controller/StarSystemController.gd")
var BattleCommand = preload("res://Scripts/Model/BattleCommand.gd")

var ControlStateMachine = preload("res://Scenes/Components/Battle/States/Control/ControlStateMachine.gd").new()

# Viewport for the 3D screen
onready var viewport = get_node("BattleViewport/Viewport")
# Viewport Sprite
onready var vp_sprite = get_node("BattleViewport/ViewportSprite")

# 3D Display Elements
onready var battle_root = get_node("BattleViewport/Viewport/battle_root")
onready var battle_center = get_node("BattleViewport/Viewport/battle_root/battle_center")

# UI Elements
onready var top_buttons = get_node("TopButtons")
onready var item_list = get_node("ItemList")

onready var star_name = get_node("TopButtons/Overview/Star Name")
onready var star_type = get_node("TopButtons/Overview/Star Type")
onready var star_sprite = get_node("TopButtons/Overview/Star")

# Tooltip
onready var tooltip_label = get_node("BattleTooltip")

# UI controls
onready var left = get_node("BottomButtons/Left")
onready var right = get_node("BottomButtons/Right")

# FIXME: these are technically zoom in and out controls
onready var up = get_node("BottomButtons/Up")
onready var down = get_node("BottomButtons/Down")

onready var radar = get_node("BottomButtons/Radar")
onready var grid = get_node("BottomButtons/Grid")

# UI Displays
onready var planet_display = get_node("TopButtons/Planet/PlanetAnchor/PlanetDisplay")
onready var ship_display = get_node("TopButtons/Ships/ShipAnchor/ShipDisplay")

onready var list_own = get_node("TopButtons/Overview/Controls/ListOwn")
onready var list_other = get_node("TopButtons/Overview/Controls/ListOther")

# signals
signal planet_picked(planet)
signal ship_picked(ship)
signal repainted

var current_system = null
onready var current_selection = BattleSelection.new()

enum control_mode {NONE, PLANET, SHIP, SHIP_MOVE_REQUEST, SHIP_MOVE_CONFIRM, TARGETING}
enum screen_mode {NONE, PLANET, SHIP, OWN_ITEMS, OTHER_ITEMS}
enum animation_mode { NONE, WAIT }

var current_control_mode = control_mode.NONE
var current_screen_mode = screen_mode.NONE
var current_animation_mode = animation_mode.NONE

var currently_hovering = false
var current_coordinate = null

var command_queue = []
var currently_animated = null

# Screen starts on battle time / list controls + planet list
# selecting any planet changes top display to planet name + icon
# clicking in empty space reverts to default, even if player was on foreign items list
# clicking a ship switches to ship view / module view and ship movement targeting
# right-clicking empty space deselects
# right-clicking object in list focuses (planet, ship)
# right-clicking object in space focuses, even in targeting mode
# right-clicking during movement of anything skips to the end state
# targeting draws a line
# movement targeting is scary, I don't know where to start
# enemy ships can be selected but show empty module lists (unless you have scanners + x-ray)
# observation installation shows power levels on cloaked and uncloaked ships in range, but not modules
# can't see modules of ships with scanners, but without x-ray megaglasses (but scanners also talk about only showing status)

func _ready():
	# set up magic numbers between viewport and 3d view
	var rect_size = viewport.get_rect().size
	battle_root.width2d = rect_size.width
	battle_root.height2d = rect_size.height

	# TODO: unify rotation directions
	left.connect("button_down", self, "_on_rotate", [-1])
	left.connect("button_up", self, "_on_rotate", [0])
	right.connect("button_down", self, "_on_rotate", [1])
	right.connect("button_up", self, "_on_rotate", [0])

	up.connect("button_down", self, "_on_zoom", [-1])
	up.connect("button_up", self, "_on_zoom", [0])
	down.connect("button_down", self, "_on_zoom", [1])
	down.connect("button_up", self, "_on_zoom", [0])
	
	radar.connect("toggled", battle_root, "display_lines")
	grid.connect("toggled", battle_root, "display_grid")
	
	# this will break when I drill down to the planet
	connect("visibility_changed", self, "_maybe_refresh")

	# connect to battle3d events
	battle_root.connect("battle_object_clicked", self, "_on_battle_object_picked")
	battle_root.connect("battle_object_hover_begin", self, "_on_battle_object_hover_begin")
	battle_root.connect("battle_object_hover_end", self, "_on_battle_object_hover_end")
	battle_root.connect("any_click", self, "_on_any_click")
	battle_root.connect("state_now_dirty", self, "set", ["trigger_update", true])

	# connect to viewportsprite
	vp_sprite.connect("vp_hover_end", self, "_on_vp_hover_end")

	# connect to the controls in the subscreens
	list_own.connect("pressed", self, "_on_list_own_clicked")
	list_other.connect("pressed", self, "_on_list_other_clicked")

	# connect to the item list's signals
	item_list.connect("planet_picked", self, "planet_clicked")

	set_process(true)
	pass

func _process(delta):
	ControlStateMachine.process(delta)
	# TODO: move commands to some battlescreencontroller
	# TODO: animate inside battle3d
	# not currently animating, grab the next command
	if current_animation_mode == animation_mode.NONE:
		if command_queue.size() > 0:
			var battle_object = command_queue.front()
			command_queue.pop_front()
			current_animation_mode = animation_mode.WAIT
			currently_animated = battle_object
	
	if current_animation_mode == animation_mode.WAIT:
		if currently_animated != null:
			if currently_animated.command.command_type == BattleCommand.COMMAND.MOVE:
				# TODO: check for null position
				if currently_animated.position == null:
					print("arrived")

				# TODO: this needs to change
				# The initial movement command needs to determine the distance and store it in a travel_distance
				# every subsequent tick must not only move the object, but also keep track of the distance moved and deduct it from travel_distance
				# this should - in theory - prevent both overshooting and wiggle,
				# because the final tick (where remaining travel_distance might be smaller than tick distance) can just move the remaining travel distance
				var movement_target_position = currently_animated.command.target
				var mover_position = currently_animated.position
				
				var movement_vector = movement_target_position - mover_position
				### 
				# TODO: move as far as the ship's engines allow
				StarSystemController.move_ship(currently_animated)
				###

				var movement_chunk = movement_vector.normalized()
				var ship_movement_per_frame = movement_chunk * delta

				var remaining_distance = movement_vector.length()
				var ship_moves_this_far = ship_movement_per_frame.length()
				#print(remaining_distance - ship_moves_this_far)

				if ship_moves_this_far >= remaining_distance or remaining_distance <= 0.1:
					print("should have arrived now")
					if currently_animated.command.target_object != null:
						var arrived = false
						var destination = currently_animated.command.target_object
						if destination extends StarLane:
							var entered_starlane = ShipController.enter_starlane(destination, currently_animated)
							if entered_starlane:
								# remove ship, animate starlane
								prints("entered", destination, entered_starlane)
								arrived = true
								pass
							else:
								# bump ship back
								pass
						elif destination extends Planet:
							var docked = ShipController.attempt_orbit(destination, currently_animated)
							if docked:
								prints("docked", destination, docked)
								# remove ship
								arrived = true
								pass

						if arrived:
							current_animation_mode = animation_mode.NONE
							currently_animated.command.reset()
							currently_animated = null
				else:
					#print("keep moving")
					currently_animated.position += ship_movement_per_frame
					#battle_root.object_map[currently_animated].translate(ship_movement_per_frame)

				#<<<<<<<<<<<<<<<
				return
				#>>>>>>>>>>>>>>>
				if movement_vector.length() > 4 * delta:
					movement_vector = movement_vector.normalized()
					currently_animated.position += movement_vector * 3 * delta
					#battle_root.animate_object(currently_animated.command, movement_vector)
					#battle_root.object_map[currently_animated].translate(movement_vector * 3 * delta)
					#currently_animated.command.actor.translate(movement_vector * delta)
				else:
					# TODO: finish command, whatever that means (chain into explosion, deal damage etc)
					# TODO: needs a BattleProjectile class that holds damage and/or VFX data
					if currently_animated.command.target_object != null:
						var from = currently_animated
						var to = from.command.target_object
						var arrived = false
						if to extends StarLane:
							if (from.position - from.command.target).length() <= 0.01:
								var entered_starlane = ShipController.enter_starlane(to, from)
								
								if entered_starlane:
									current_selection.reset()
									battle_root.remove_display_for_object(currently_animated)
									arrived = true

						elif to extends Planet:
							if (from.position - to.position).length() <= 0.01:
								var docked = ShipController.attempt_orbit(to, from)
								if docked:
									current_selection.reset()
									battle_root.remove_display_for_object(currently_animated)
									#battle_root.object_map[currently_animated].queue_free()
									arrived = true

						if arrived:
							current_animation_mode = animation_mode.NONE
							currently_animated.command.reset()
							currently_animated = null
					else:
						current_animation_mode = animation_mode.NONE
						if currently_animated != null:
							currently_animated.command.reset()
							currently_animated = null
		else:
			current_animation_mode = animation_mode.NONE
	pass

func set_payload(payload):
	set_system(payload)

# TODO: update when returning from planet screen, for example because of colonies cheated in or ships entering / leaving orbit
# probably will be using a signal
func _maybe_refresh():
	# multiple possible entry points exist for the battle screen
	# 1: from the galaxy view, player clicked on a star system
	# 2: from the planet list, player clicked on the star
	# 3: from an event, ship entered a player system
	# 4: from an event, a hostile ship entered or still is in a player system
	if current_system != null and trigger_update:
		if is_visible() == true:
			set_system(current_system)
	pass

func set_system(system):
	# update 3D display
	battle_root.set_system(system)
	# feed it the galaxy for background stars
	# TODO: find reasonable place for game_state access / passing in
	battle_root.set_background_stars(system, GameStateHandler.game_state.galaxy)
	# update UI
	update_ui(system)
	current_system = system
	# TODO: reset control mode
	# TODO: reset screen mode
	update_screen_mode(screen_mode.NONE)
	# TODO: reset selection
	current_selection.reset()
	#print(get_tree().get_nodes_in_group("battlescreen_vp_hover").size())
	trigger_update = false
	pass
	
func update_ui(system):
	star_name.set_text(system.system_name)
	star_type.set_text(system.star_type.capitalize())
	star_sprite.set_texture(TextureHandler.get_star(system))
	item_list.view_own_items(GameStateHandler.game_state.human_player, system)

func hide_top_display():
	for c in top_buttons.get_children():
		c.hide()

func update_screen_mode(mode):
	if mode != current_screen_mode:
		hide_top_display()
		if mode == screen_mode.NONE:
			top_buttons.get_node("Overview").show()
			pass
		elif mode == screen_mode.PLANET:
			top_buttons.get_node("Planet").show()
			pass
		elif mode == screen_mode.SHIP:
			top_buttons.get_node("Ships").show()
			#item_list.show_inventory()
			pass
		elif mode == screen_mode.OWN_ITEMS:
			top_buttons.get_node("Overview").show()
			#item_list.show_own_items()
			pass
		elif mode == screen_mode.OTHER_ITEMS:
			top_buttons.get_node("Overview").show()
			#item_list.show_other_items()
			pass
		current_screen_mode = mode

func planet_clicked(planet):
	var sprite = battle_root.object_map[planet]
	planet_display.set_planet(planet)
	update_screen_mode(screen_mode.PLANET)
	# TODO: update planet display (single item display)
	# TODO: module visibility depends on player, scanners (?) etc
	item_list.view_planet_modules(GameStateHandler.game_state.human_player, planet)

	if current_selection.battle_object != null:
		if current_selection.battle_object extends Planet:
			if current_selection.battle_object == planet:
				emit_signal("planet_picked", planet)
			else:
				current_selection.sprite = sprite
				current_selection.battle_object = planet
		elif current_selection.battle_object extends Ship:
			# TODO: issuing a command deselects the ship
			if current_control_mode == control_mode.SHIP:
				# FIXME: this can fill the command queue if you click very quickly, have to rethink the whole thing
				ShipController.command_move_to_planet(current_selection.battle_object, planet)
				# this would be clever but those areas don't exist unless we're on this screen, but ships can and will move through systems even when not visible
				# var ship_sprite = current_selection.sprite
				# ship_sprite.click_area.connect("area_enter", self, "_on_ship_area_entered", [sprite.click_area])
				command_queue.append(current_selection.battle_object)
				current_control_mode = control_mode.NONE
				current_selection.reset()
			pass
	else:
		current_selection.sprite = sprite
		current_selection.battle_object = planet
		pass
	pass

func starlane_clicked(starlane):
	var sprite = battle_root.object_map[starlane]
	if current_selection.battle_object != null:
		if current_selection.battle_object extends Ship:
			if current_control_mode == control_mode.SHIP:
				# FIXME: this can fill the command queue if you click very quickly, have to rethink the whole thing
				ShipController.command_move_to_starlane(current_selection.battle_object, starlane)
				command_queue.append(current_selection.battle_object)
				current_control_mode = control_mode.NONE
				current_selection.reset()
	pass

func ship_clicked(ship):
	var sprite = battle_root.object_map[ship]
	ship_display.set_ship(ship)

	update_screen_mode(screen_mode.SHIP)

	# TODO: module visibility depends on player, scanners etc
	item_list.view_ship_modules(ship.owner, ship, "weapons")
	if current_selection.battle_object == null:
		if ship.owner == GameStateHandler.game_state.human_player:
			current_selection.battle_object = ship
			current_selection.sprite = sprite
			current_control_mode = control_mode.SHIP

	pass

func space_clicked(event, coords, rotation):
	# TODO: will probably extract this into a click (space / not space) handler
	if current_selection.battle_object != null:
		if current_selection.battle_object extends Ship:
			# targeting space with a ship selected
			if current_control_mode == control_mode.SHIP:
				# TODO: program all of it
				# if in ship control mode, the next click is a movement target. since we're in space click, it was a click in empty space, not on an object
				# send x-y coordinates to ? and switch to ship_move_request mode, which waits for another click
				# targeting projects the flat 2d coordinates onto the 3D plane which is then drawn as a grid
				#  take the 2D coordinates, transform them into -1 .. +1 space on X and Y
				#  scale the resulting vector according to grid size (& zoom factor) so that it fits
				#  draw a 3d gizmo at (x, y, 0) on update
				ShipController.command_move_in_system(current_selection.battle_object, coords.rotated(Vector3(0, 1, 0), rotation.y) * 15)
				# TODO: find and assign sprite
				# current_selection.command.actor = sprite
				command_queue.append(current_selection.battle_object)
				current_control_mode = control_mode.NONE
				current_selection.reset()
				pass
			elif current_control_mode == control_mode.SHIP_MOVE_REQUEST:
				# send z coordinate to ? and switch to ship_move_confirm, which optionally accepts a right click to skip the animation
				pass
			elif current_control_mode == control_mode.SHIP_MOVE_CONFIRM:
				pass
			pass
		elif current_selection.battle_object extends Planet:
			# empty space click = deselect planet
			update_screen_mode(screen_mode.NONE)
			item_list.view_own_items(GameStateHandler.game_state.human_player, current_system)
			current_selection.reset()
			pass
		elif current_selection.battle_object extends PlanetModule:
			# check if it can be targeted and fired
			pass
		elif current_selection.battle_object extends ShipModule:
			# check if it can be targeted and fired (onto ships, or into space, or immediately)
			pass
	else:
		# no selection > reset to default?
		pass


func _on_any_click(event, coords, rotation):
	if currently_hovering == false:
		#print(coords)
		space_clicked(event, coords, rotation)

func _on_rotate(direction):
	battle_root.spin_direction = direction

func _on_zoom(direction):
	battle_root.zoom_direction = direction
	
func _on_battle_object_picked(object):
	if object extends Planet:
		planet_clicked(object)
	elif object extends Ship:
		ship_clicked(object)
	elif object extends StarLane:
		starlane_clicked(object)
	pass

func _on_battle_object_hover_begin(object):
	var current_player = GameStateHandler.game_state.human_player
	# TODO: planet name tooltip
	if object extends Planet:
		tooltip_label.set_text(object.planet_name)
	if object extends StarLane:
		var knowledge = current_player.knowledge
		if knowledge and knowledge.lanes.has(object):
			tooltip_label.set_text(object.from_to(current_system))
		else:
			tooltip_label.set_text("Star Lane")
	if object == current_system:
		tooltip_label.set_text(current_system.system_name)
	if object extends Ship:
		var ship_label = ""
		if object.owner != current_player:
			ship_label = "%s %s" % [object.owner.race.race_name.capitalize(), object.size.capitalize()]
		else:
			ship_label = object.ship_name
		tooltip_label.set_text(ship_label)
		
	# TODO: star lane tooltip using player knowledge
	# TODO: ship tooltip
	# TODO: star tooltip
	# TODO: control mode: normal
	# TODO: control mode: targeting
	# TODO: cursor change
	currently_hovering = true
	pass

func _on_battle_object_hover_end(object):
	tooltip_label.set_text("")
	currently_hovering = false
	pass

func _on_vp_hover_end():
	tooltip_label.set_text("")
	if get_tree().has_group("battlescreen_vp_hover"):
		get_tree().call_group(0, "battlescreen_vp_hover", "mouse_exit")

func _on_list_own_clicked():
	print("showing own")
	item_list.view_own_items(GameStateHandler.game_state.human_player, current_system)

func _on_list_other_clicked():
	item_list.view_other_items(GameStateHandler.game_state.human_player, current_system)

func _on_ship_area_entered(area, expected):
	if area == expected:
		# ship arrived at designated target
		print("ship arrived at planet")
