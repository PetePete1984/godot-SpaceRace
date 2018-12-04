extends Spatial

onready var anchor = get_node("battle_center")
onready var line_drawer = anchor.get_node("line_drawer")
onready var grid = anchor.get_node("Grid")

onready var movement_spatial = get_node("move_spatial")
onready var movement_line = movement_spatial.get_node("movement_line")

onready var camera = get_node("camera")

const SPIN_SPEED = 360.0/5
const ZOOM_SPEED = 10.0
const SCALE_FACTOR = 1
var DISPLAY_SCALE = Vector3(SCALE_FACTOR,SCALE_FACTOR,SCALE_FACTOR) #Vector3(0.2, 0.2, 0.2)

#var StarSystemGenerator = preload("res://Scripts/Generator/StarSystemGenerator.gd")

var Planet = preload("res://Scripts/Model/Planet.gd")
var Planetmap = Classes.Planetmap
#var SmallPlanetSprite = preload("res://Scenes/Components/Battle/SmallPlanetSprite.gd")
var BattlePick = preload("res://Scenes/Components/ClickableArea3D.gd")
var BillboardSprite3D = preload("res://Scenes/Components/BillboardSprite3D.tscn")

var sprites = []

# dictionary that maps game objects (planet, ship) to their sprites
var object_map = {}

var spin_direction = 0
var zoom_direction = 0

# width of the parent viewport, assigned from BattleScreen
var width2d
# height of the parent viewport
var height2d

var current_control_mode = "move1"
var current_coord = Vector3(0, 0, 0)

signal battle_object_clicked(object)
signal battle_object_hover_begin(object)
signal battle_object_hover_end(object)

signal sprites_cleared
signal sprites_repainted
signal rotated
signal zoomed
signal reset
signal pivot_changed

signal any_click(event, coords, rotation)

func _ready():
	#randomize()
	#_create_random_system()
	set_process(true)
	set_process_unhandled_input(true)
	pass
	
func _process(delta):
	if spin_direction != 0:
		rotate(delta, spin_direction)
	if zoom_direction != 0:
		zoom(delta, zoom_direction)

	# TODO: use enum
	# TODO: use signals for mousemove input and don't update at 60 fps if unchanged
	# TODO: the cursor moves in global space, so you can control it even if the view is rotated
	if current_control_mode == "move1":
		movement_spatial.set("geometry/visible", true)
		# TODO: find out correct factor, include zoom
		# TODO: account for rotation
		movement_spatial.set_translation(current_coord * 15)
	elif current_control_mode == "move2":
		movement_spatial.set("geometry/visible", true)
	else:
		movement_spatial.set("geometry/visible", false)
	pass

func _unhandled_input(event):
	# TODO: maybe use the Plane class and its intersects_ray method
	if event.type == InputEvent.MOUSE_MOTION:
		var x = event.pos.x
		var y = event.pos.y
		# TODO: use viewport's size
		x -= width2d / 2.0 # 230
		y -= height2d / 2.0 # 233
		x = x / (width2d / 2.0) # 230.0
		y = y / (height2d / 2.0) # 233.0
		current_coord = Vector3(x, 0, y)
		#print(current_coord)
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				emit_signal("any_click", event, current_coord, anchor.get_rotation())
			elif event.button_index == BUTTON_RIGHT:
				# TODO: implement right click signal to accelerate movement / commands
				pass
	pass

func rotate(delta, direction):
	if direction != 0:
		# TODO: rotations are flipped compared to base game
		anchor.rotate_y(deg2rad(SPIN_SPEED*delta*direction))
		emit_signal("rotated")

func zoom(delta, direction):
	if direction != 0:
		camera.fov += delta*ZOOM_SPEED*direction
		emit_signal("zoomed")
	
func display_grid(display = true):
	grid.set("geometry/visible", display)

func display_lines(display = true):
	line_drawer.set("geometry/visible", display)

func clear_display():
	# FIXME: clear sun sprite
	# TODO: has trouble when undocking a ship for the second time
	for spr in sprites:
		#print(spr.get_name())
		if spr.has_node("area"):
			#print(spr.get_node("area").get_signal_connection_list("clicked"))
			#spr.get_node("area").disconnect("battle_object_clicked", self, "battle_object_clicked")
			pass
		spr.hide()
		spr.call_deferred("queue_free")
		#spr.get_parent().remove_child(spr)
	sprites.clear()
	object_map.clear()
	emit_signal("sprites_cleared")

func remove_display_for_object(battle_object):
	var sprite = object_map[battle_object]
	sprites.erase(sprite)
	object_map.erase(battle_object)
	sprite.call_deferred("queue_free")

func set_system(system):
	generate_starsystem_display(system)
	line_drawer.set_system(system)
	emit_signal("sprites_repainted")
	pass
	
func generate_starsystem_display(system):
	clear_display()
	var sys = system
	
	# get and draw the star
	var sun_sprite = get_clickable(TextureHandler.get_star(system), Vector3(0, mapdefs.system_default_y, 0), system.system_name, system)
	# var sun_sprite = BillboardSprite3D.instance()
	# sun_sprite.depth_cue = false
	# sun_sprite.set_texture(TextureHandler.get_star(system))
	# sun_sprite.set_scale(DISPLAY_SCALE)
	# sun_sprite.set_translation(Vector3())
	# sun_sprite.translate(Vector3(0, mapdefs.system_default_y, 0))
	# sun_sprite.set_name(system.system_name)
	# anchor.add_child(sun_sprite)
	sprites.append(sun_sprite)
	object_map[system] = sun_sprite
		
	# draw the system's star lanes
	# TODO: split lanes into lanes + lane exits
	for lane_pos in sys.lanes:
		var lane = sys.lanes[lane_pos]
		#var lane_sprite = BillboardSprite3D.instance()
		var connects_to
		for i in lane.connects:
			if i != sys:
				connects_to = i.system_name
		var lane_sprite = get_clickable(TextureHandler.get_starlane(lane), lane_pos, "Star Lane to %s" % [connects_to], lane)
		# lane_sprite.depth_cue = false
		# lane_sprite.set_texture(TextureHandler.get_starlane(lane))
		# lane_sprite.set_scale(DISPLAY_SCALE)
		# lane_sprite.set_translation(lane_pos)

		# lane_sprite.set_name("Star Lane to %s" % [connects_to])
		# anchor.add_child(lane_sprite)
		sprites.append(lane_sprite)
		object_map[lane] = lane_sprite
	
	# draw the system's planets
	# and assign them clickables
	for planet in sys.planets:
		var planet_sprite = get_clickable(TextureHandler.get_planet(planet, true), planet.position, planet.planet_name, planet)

		# FIXME: this drawing hack must be nicer later, when the list is implemented
		var has_owner = false
		if planet.owner != null:
			has_owner = true
		if has_owner:
			# TODO: if planet size doesn't match home sprite size, resize collision box
			# TODO: show colored outlines when ships or shields are in orbit
			#planet_sprite.set_scale(Vector3(4,4,4))
			pass
		
		sprites.append(planet_sprite)
		object_map[planet] = planet_sprite

	for ship in system.ships:
		var ship_sprite = get_clickable(TextureHandler.get_ship(ship.owner, ship.size), ship.position, ship.ship_name, ship)
		sprites.append(ship_sprite)
		object_map[ship] = ship_sprite
	pass

func get_clickable(obj_texture, obj_position, obj_name, obj_as_signal_param):
	var new_sprite = BillboardSprite3D.instance()

	new_sprite.depth_cue = false
	new_sprite.set_translation(obj_position)
	new_sprite.set_scale(DISPLAY_SCALE)
	new_sprite.set_texture(obj_texture)

	# clickable area
	var area3d = BattlePick.new()
	area3d.set_monitorable(true)
	area3d.set_enable_monitoring(true)
	area3d.set_ray_pickable(true)
	area3d.set_name("area")
	
	# sprite size * math = area shape
	var sprite_x = new_sprite.get_texture().get_width()
	var sprite_y = new_sprite.get_texture().get_height()
	var unit_pixel_ratio = new_sprite.get_pixel_size()

	# clickable area shape
	var collisionShape = CollisionShape.new()
	
	# Box mode
	#var assignedShape = BoxShape.new()
	
	# divide by 2 because extents are doubled size
	#assignedShape.set_extents(Vector3(sprite_x, sprite_y, 1) * unit_pixel_ratio / 2)

	# Sphere mode
	var assignedShape = SphereShape.new()
	assignedShape.set_radius(max(sprite_x, sprite_y) * unit_pixel_ratio / 2)
	# TODO: ships are images with lots of empty space because the max ship size dictates the max image size, so the sphere shape doesn't quite fit

	collisionShape.set_shape(assignedShape)
	area3d.add_shape(assignedShape)
	area3d.add_child(collisionShape)
	
	# add collision area to object
	new_sprite.add_child(area3d)
	new_sprite.set_name(obj_name)
	new_sprite.click_area = area3d
	
	# connect to area's click signal for object picking
	# TODO: maybe need to pass more than the object upwards, because the screen needs to tell the specific sprite to move in process
	# also the entirety of sprite + 3d line needs to move
	# TODO: the line isn't rendered during ship movement
	area3d.connect("clicked", self, "_on_battle_object_clicked", [obj_as_signal_param])
	area3d.connect("hover_begin", self, "_on_battle_object_hover_begin", [obj_as_signal_param])
	area3d.connect("hover_end", self, "_on_battle_object_hover_end", [obj_as_signal_param])
	
	# add object sprite to object anchor
	anchor.add_child(new_sprite)
	return new_sprite

func _on_battle_object_clicked(object):
	emit_signal("battle_object_clicked", object)

func _on_battle_object_hover_begin(object):
	object_map[object].get_node("area").add_to_group("battlescreen_vp_hover")
	emit_signal("battle_object_hover_begin", object)
	
func _on_battle_object_hover_end(object):
	if object_map[object].get_node("area").is_in_group("battlescreen_vp_hover"):
		object_map[object].get_node("area").remove_from_group("battlescreen_vp_hover")
	emit_signal("battle_object_hover_end", object)

#func _create_random_system():
#	var sys = StarSystemGenerator.generate_system()
#	generate_starsystem_display(sys)
#	pass