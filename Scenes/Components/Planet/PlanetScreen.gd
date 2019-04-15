extends "res://Scripts/Model/Screen.gd"

# none = planet, colony = building a colony base, normal = colony base exists
# possible states:
# - viewing empty planet
# - viewing empty planet, own ship in orbit
# - viewing own colony
# - viewing own colony, own ship in orbit
# - viewing foreign colony
# - viewing foreign colony, own ship in orbit
# TODO: use control mode to change input behavior
enum control_mode {NONE, COLONY, NORMAL}

var Planetmap = preload("res://Scripts/Planetmap.gd")
var ColonyManager = preload("res://Scripts/Manager/ColonyManager.gd")
var ColonyController = preload("res://Scripts/Controller/ColonyController.gd")
var ColonyGenerator = preload("res://Scripts/Generator/ColonyGenerator.gd")
var BuildingProject = preload("res://Scripts/Model/BuildingProject.gd")

var PlanetShipSprite = preload("res://Scenes/Components/Planet/PlanetShipSprite.tscn")
var BasicPopup = preload("res://Scenes/Components/Planet/Popup/BasicPopup.tscn")
var RenamePopup = preload("res://Scenes/Components/RenamePopup.tscn")

var ShipCommandPopup = preload("res://Scenes/Components/Planet/Popup/ShipCommandPopup.gd")
var ExistingBuildingPopup = preload("res://Scenes/Components/Planet/Popup/ExistingBuildingPopup.gd")
var OrbitalTilePopup = preload("res://Scenes/Components/Planet/Popup/OrbitalTilePopup.gd")
var SurfaceTilePopup = preload("res://Scenes/Components/Planet/Popup/SurfaceTilePopup.gd")

var ShipController = preload("res://Scripts/Controller/ShipController.gd")

onready var tilemap_cells = get_node("TileMapAnchor/TileMapCells")
onready var tilemap_buildings = get_node("TileMapAnchor/TileMapBuildings")
onready var tilemap_orbitals = get_node("OrbitalAnchor/TileMapOrbitals")

onready var research_display = get_node("PlanetUI/ResearchDisplay")
onready var industry_display = get_node("PlanetUI/IndustryDisplay")
onready var prosperity_display = get_node("PlanetUI/ProsperityDisplay")

onready var planet_sprite = get_node("PlanetSprite")
onready var worker_display = get_node("Workers")

onready var project_display = get_node("PlanetUI/ProjectDisplay")

onready var surface_project_sprite = get_node("TileMapAnchor/TileMapBuildings/SurfaceProjectSprite")
onready var orbital_project_sprite = get_node("OrbitalAnchor/TileMapOrbitals/OrbitalProjectSprite")

onready var surface_cursor = get_node("TileMapAnchor/surface_cursor")
onready var orbital_cursor = get_node("OrbitalAnchor/orbital_cursor")

onready var popup = get_node("PlanetUI/AcceptDialog")
onready var project_button = get_node("PlanetUI/ProjectButton")
onready var project_grid = popup.get_node("ProjectGrid")

var rename_popup

# TODO: evaluate using a signal to communicate "dirty" state to planet list screen
signal design_new_ship
signal refit_ship
signal help_requested
signal ship_named(size, modules, ship_name)
signal ship_finalized

# TODO: refactor to current_planet
var currentPlanet = null
var current_control_mode = control_mode.NORMAL
var current_ship_design

var current_picked_project

# FIXME: Orbital Tilemap offsets seem to be off entirely

func _ready():
	#set_process(true)
	# grab the tilesets of the tilemaps and make all shaders unique
	# then update the alpha_height of each sprite
	connect("hide", self, "_on_hidden")
	connect("ship_named", self, "_on_ship_named")

	tilemap_cells.connect("tile_clicked", self, "_on_cell_clicked")
	tilemap_cells.connect("tile_hover_in", self, "_on_cell_hover_in")

	tilemap_orbitals.connect("tile_clicked", self, "_on_orbital_clicked")
	tilemap_orbitals.connect("tile_hover_in", self, "_on_orbital_hover_in")

	project_button.connect("pressed", self, "_on_project_pressed")
	set_process_input(true)
	pass

func _on_project_pressed():
	# FIXME: this is for the project button on the top right, not for buttons on a popup
	pass
	
func _on_project_picked(key, tile, type):
	# FIXME: picking a project should ask the planet's colony to
	# - end all old projects (unless queue is working)
	# - start the new project at the specified position, setting the proper building tile
	# afterwards, the tilemap refresh should happen
	# TODO: special handling for ship building required
	if type == "Orbital" and key == "ship_placeholder":
		# TODO: hide popup first
		popup.hide()
		emit_signal("design_new_ship")
		# wait for return from ship design screen
		# TODO: I don't know if this is nice, needs to be basically skipped if the ship is empty
		yield(self, "ship_finalized")
		if current_ship_design != null:
			ColonyController.start_project(currentPlanet.colony, Vector2(tile.tilemap_x, tile.tilemap_y), current_ship_design)
			current_ship_design = null
	else:
		ColonyController.start_project(currentPlanet.colony, Vector2(tile.tilemap_x, tile.tilemap_y), [key, type])
	project_grid.clear_buttons()
	
	# TODO: may be obsolete
	Planetmap.get_tilemap_from_planet(currentPlanet, tilemap_cells, tilemap_buildings, tilemap_orbitals)
	_notify_displays()
	popup.hide()

# TODO: maybe add a third parameter for the signal mode (NONE, BUILD, REFIT?)
# and a fourth for the ship parameter?
func _on_left_ship_design_screen(size, modules):
	# triggered when the player leaves the ship design screen, but shouldn't be triggered when coming from the list screen
	# TODO: show a popup asking for a name, with default being the ship's size
	# TODO: I don't think you get a name popup on refits?
	# TODO: have the rename_popup be a persistent element
	var rename_popup = RenamePopup.instance()
	add_child(rename_popup)
	rename_popup.set_name("RenamePopup")
	rename_popup.set_ship_size(size)
	var result = yield(rename_popup, "popup_closed")
	#print(result)
	var ship_name = result
	emit_signal("ship_named", size, modules, ship_name)
	pass

# FIXME: this way of defining the ship design is really volatile, the simulator needs to know it, too
func _on_ship_named(size, modules, ship_name):
	current_ship_design = {
		size = size,
		modules = modules,
		ship_name = ship_name
	}
	emit_signal("ship_finalized")

func _on_ship_leave_orbit(ship, tile):
	ShipController.leave_orbit(currentPlanet, ship)
	tile.orbiting_ship = null
	trigger_update = true
	_notify_displays()

func _on_ship_colonize(ship, planet):
	var position = ColonyGenerator.generate_colony(planet, "initial")
	#ColonyGenerator.initialize_colony(GameStateHandler.game_state.human_player, currentPlanet)
	ColonyController.colonize_planet(planet, ship.owner, position, "New Colony")
	ShipController.remove_modules(ship, "colonizer")
	# TODO: maybe notify_displays can be expanded to incorporate the stuff needed here
	set_planet(currentPlanet)

func set_payload(payload):
	set_planet(payload)

# entry points
# 1: from the battle screen, player clicked on a selected planet
#  planets can be selected by clicking on them in neutral cursor mode (no attack, flight target)
#  or by picking them from the planet list (on the battle screen)
# 2: from the planet list, player clicked on a planet sprite (this bypasses the battle screen entirely)
# 3: from an event ("planet has free pop", "planet has completed project", "ship has arrived in orbit")
# 4: from the ship list, when a ship is orbiting a planet or in construction

func set_planet(planet):
	currentPlanet = planet
	generate_planet_display(planet)
	update_control_mode()

func update_control_mode():
	if currentPlanet.colony:
		if currentPlanet.colony.owner != GameStateHandler.game_state.human_player:
			current_control_mode = control_mode.NONE
		else:
			current_control_mode = control_mode.NORMAL
	else:
		# TODO: check for colony ship / colonizing mode
		current_control_mode = control_mode.NONE

func generate_planet_display(planet):
	planet_sprite.set_planet(planet)
	Planetmap.get_tilemap_from_planet(planet, tilemap_cells, tilemap_buildings, tilemap_orbitals)
	_notify_displays()
	pass

func _notify_displays():
	# TODO: these should get fed both raw and adjusted values, actually
	if currentPlanet.colony:
		research_display.set_points(currentPlanet.colony.adjusted_research)
		industry_display.set_points(currentPlanet.colony.adjusted_industry)
		prosperity_display.set_points(currentPlanet.colony.adjusted_prosperity)
		worker_display.set_population(currentPlanet)
		project_display.set_project(currentPlanet)
		#surface_project_sprite.update_progress(currentPlanet.colony.project)
		#project_display.set_project(currentPlanet)
		# TODO: add sprites for orbital display
		# TODO: find out how to handle automation (overlay?)
		surface_project_sprite.set_surface_project(tilemap_buildings, currentPlanet.colony.project)
		orbital_project_sprite.set_orbital_project(tilemap_orbitals, currentPlanet.colony.project, currentPlanet.colony.owner)
	else:
		# TODO: reset display for empty planets
		research_display.set_points(0)
		industry_display.set_points(0)
		prosperity_display.set_points(0)
		worker_display.set_population(currentPlanet)
		project_display.set_project(currentPlanet)
		surface_project_sprite.update_progress(null)
		orbital_project_sprite.update_progress(null)

	# always get ship orbitals because these might be there on a fresh planet, or might be ships from others
	draw_ships()
	pass

func draw_ships():
	for c in tilemap_orbitals.get_children():
		if c.is_in_group("planet_ship_sprite"):
			c.hide()
			c.queue_free()
	var orbitals = currentPlanet.orbitals
	var colony = currentPlanet.colony
	for x in range(orbitals.size()):
		for y in range(orbitals[x].size()):
			var orbital = orbitals[x][y]
			if orbital.type == null and orbital.orbiting_ship != null:
				var ship = orbital.orbiting_ship
				var sprite = PlanetShipSprite.instance()
				tilemap_orbitals.add_child(sprite)
				sprite.set_ship(ship)
				sprite.set_pos(tilemap_orbitals.map_to_world(Vector2(x, y)))
				sprite.tile_position = Vector2(x, y)
				# TODO: connect to click command or leave that to orbital tilemap
				#sprite.connect("clicked")

func _on_hidden():
	surface_cursor.hide()
	orbital_cursor.hide()

func _process(delta):
	pass

# TODO: swap to _unhandled_input to let UI intercept inputs
func _input(event):
	# TODO: when there is already a project picked and stuck to the mouse, the behavior changes
	# fields that can't be built on don't react to the cursor
	if not is_visible():
		return
	if popup.is_visible():
		if event.is_action_pressed("ui_cancel"):
			popup.hide()
			get_tree().set_input_as_handled()
		return
	if has_node("RenamePopup"):
		if event.is_action_pressed("ui_cancel"):
			get_node("RenamePopup")._on_confirm_name()
			get_tree().set_input_as_handled()
	
	# DEBUG
	if event.is_action_pressed("ui_down"):
		print(ColonyManager.manage(currentPlanet.colony))
	if event.is_action_pressed("ui_up"):
		if currentPlanet.colony == null:
			ColonyGenerator.initialize_colony(GameStateHandler.game_state.human_player, currentPlanet)
			set_planet(currentPlanet)
	if event.is_action_pressed("ui_right"):
		emit_signal("design_new_ship")
	
	# hover display
	# TODO: might just live on the tilemap?
	if event.type == InputEvent.MOUSE_MOTION and currentPlanet != null and false:
		var relative_mouse_pos_orbital = tilemap_orbitals.get_local_mouse_pos()
		var tilemap_orbitals_pos = tilemap_orbitals.world_to_map(relative_mouse_pos_orbital)
		# FIXME: can this be done better?
		if tilemap_orbitals_pos.x in range(0,2) and tilemap_orbitals_pos.y in range(0,5):
			var orbital_cell = tilemap_orbitals.get_cellv(tilemap_orbitals_pos)
			#if orbital_cell != -1:
			orbital_cursor.set_pos(tilemap_orbitals.map_to_world(tilemap_orbitals_pos))
			orbital_cursor.show()
		else:
			if orbital_cursor.is_visible():
				orbital_cursor.hide()
		
		var relative_mouse_pos = tilemap_cells.get_local_mouse_pos()
		var tilemap_cells_pos = tilemap_cells.world_to_map(relative_mouse_pos)
		var cell = tilemap_cells.get_cellv(tilemap_cells_pos)
		if cell != -1:
			surface_cursor.set_pos(tilemap_cells.map_to_world(tilemap_cells_pos))
			surface_cursor.show()
		else:
			if surface_cursor.is_visible():
				surface_cursor.hide()
	
	# actual input
	if event.type == InputEvent.MOUSE_BUTTON and currentPlanet != null:
		if event.button_index == BUTTON_LEFT and event.pressed:
			# determine if planet tilemap or orbital tilemap was clicked
			pass
	pass

# If planet is uninhabited, clicking tilemaps, resource displays and project display does nothing; Workers button shows planet info; all top panels beep though, indicating a reaction
# If planet is enemy colony, same as above
# If planet is player colony, tilemaps highlight, panels highlight and react to clicks
# If a player has a ship on an enemy colony, nothing reacts to clicks except the ship; after invasion success it's a normal colony
# Same for uncolonized, but the colony-stuck-to-cursor mode interacts with planet tiles
# Project-stuck-to-cursor interacts with appropriate grid
# Hovering over enemy ships does nothing
# Trying to orbit a planet that has all orbital slots filled ejects the ship immediately

func _on_cell_hover_in(cell, pos):
	if cell != -1:
		surface_cursor.set_pos(tilemap_cells.map_to_world(pos))
		surface_cursor.show()
	else:
		if surface_cursor.is_visible():
			surface_cursor.hide()

func _on_cell_clicked(cell, pos):
	if current_control_mode == control_mode.NONE:
		return
		
	if cell != -1:
		if current_control_mode == control_mode.COLONY:
			ColonyController.colonize_planet(currentPlanet, GameStateHandler.game_state.human_player, pos)
			# TODO: update everything and set control mode
			pass
		elif current_control_mode == control_mode.NORMAL:
			var tile_under_mouse = currentPlanet.grid[pos.x][pos.y]
			var building_under_mouse = currentPlanet.buildings[pos.x][pos.y]
			if tile_under_mouse.tiletype != null or building_under_mouse.type != null:
				if building_under_mouse.type != null:
					var text = "%s on %s square, %s %s" % [building_under_mouse.type.building_name, tile_under_mouse.tiletype.capitalize(), pos.x, pos.y]
					# TODO: Normal behaviour is a popup that allows abandon or automate!!
					var buildings = project_grid.get_projects_for_surface(currentPlanet, tile_under_mouse, building_under_mouse)
					var textbut = project_grid.get_sprites_for_projects(buildings, tile_under_mouse)
					for tb in textbut:
						tb.connect("project_picked", self, "_on_project_picked")
					project_grid.set_buttons_on_container(textbut)
					#text += "\n%s" % str(buildings)
					popup.set_text(text)
					popup.call_deferred("popup_centered_ratio")
					#print(text)
				else:
					var text = "%s square, score: %02d, %s %s" % [tile_under_mouse.tiletype.capitalize(), tile_under_mouse.score, pos.x, pos.y]
					if tile_under_mouse.buildable and current_control_mode == control_mode.NORMAL:
						var buildings = project_grid.get_projects_for_surface(currentPlanet, tile_under_mouse, building_under_mouse)
						var textbut = project_grid.get_sprites_for_projects(buildings, tile_under_mouse)
						for tb in textbut:
							tb.connect("project_picked", self, "_on_project_picked")
						project_grid.set_buttons_on_container(textbut)
						#text += "\n%s" % str(buildings)
					else:
						project_grid.clear_buttons()
					popup.set_text(text)
					popup.call_deferred("popup_centered_ratio")
					#print(thingo)
		#print(tilemap_cells_pos)
		#var cell = tilemap_cells.get_cell(tilemap_cells_pos.x, tilemap_cells_pos.y)			

func _on_orbital_hover_in(cell, pos):
	if pos.x in range(0, 2) and pos.y in range(0,5):
		orbital_cursor.set_pos(tilemap_orbitals.map_to_world(pos))
		orbital_cursor.show()
	else:
		if orbital_cursor.is_visible():
			orbital_cursor.hide()

func _on_orbital_clicked(cell, pos):
	# orbital handling
	if current_control_mode == control_mode.NONE:
		pass
	
	if pos.x in range(0,2) and pos.y in range(0,5):
		var orbital_cell = currentPlanet.orbitals[pos.x][pos.y]

		if orbital_cell.orbiting_ship != null:
			# TODO: popup ship control
			var ship = orbital_cell.orbiting_ship
			var text = "%s %s" % [ship.owner, ship.ship_name]
			var ship_popup = BasicPopup.instance()
			ship_popup.set_script(ShipCommandPopup)
			ship_popup.add_to_group("overlay_popup")
			add_child(ship_popup)
			ship_popup.setup_for_ship(ship, currentPlanet)
			ship_popup.connect("leave_orbit", self, "_on_ship_leave_orbit", [ship, orbital_cell])
			ship_popup.connect("colonize", self, "_on_ship_colonize", [ship, currentPlanet])
			pass
		elif orbital_cell.type != null:
			# occupied tile
			# TODO: popup orbital building control
			var text = "%s, %s %s" % [orbital_cell.type.orbital_name, pos.x, pos.y]
			pass
		else:
			# TODO: popup orbital cell control
			var text = "Orbital squares can be used to anchor orbital structures"
			var orbitals = project_grid.get_projects_for_orbit(currentPlanet, orbital_cell)
			var textbut = project_grid.get_sprites_for_projects(orbitals, orbital_cell, "Orbital", currentPlanet.owner)
			for tb in textbut:
				tb.connect("project_picked", self, "_on_project_picked")
			project_grid.set_buttons_on_container(textbut)
			popup.set_text(text)
			popup.call_deferred("popup_centered_ratio")
			pass