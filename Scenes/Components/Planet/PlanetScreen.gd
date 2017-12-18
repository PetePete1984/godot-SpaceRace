extends "res://Scripts/Model/Screen.gd"

# none = planet, colony = building a colony base, normal = colony base exists
# TODO: use control mode to change input behavior
enum control_mode {NONE, COLONY, NORMAL}

var currentPlanet = null
var current_control_mode = control_mode.NORMAL

var PlanetMap = preload("res://Scripts/Planetmap.gd")
var BuildingProject = preload("res://Scripts/Model/BuildingProject.gd")

onready var tilemap_cells = get_node("TileMapAnchor/TileMapCells")
onready var tilemap_buildings = get_node("TileMapAnchor/TileMapBuildings")

onready var research_display = get_node("PlanetUI/ResearchDisplay")
onready var industry_display = get_node("PlanetUI/IndustryDisplay")
onready var prosperity_display = get_node("PlanetUI/ProsperityDisplay")

onready var planet_sprite = get_node("PlanetSprite")
onready var worker_display = get_node("Workers")

onready var project_display = get_node("PlanetUI/ProjectDisplay")

onready var surface_project_sprite = get_node("TileMapAnchor/TileMapBuildings/SurfaceProjectSprite")

onready var surface_cursor = get_node("TileMapAnchor/surface_cursor")

onready var popup = get_node("PlanetUI/AcceptDialog")
onready var project_button = get_node("PlanetUI/ProjectButton")
onready var project_grid = popup.get_node("ProjectGrid")


func _ready():
	#set_process(true)
	# grab the tilesets of the tilemaps and make all shaders unique
	# then update the alpha_height of each sprite
	connect("hide", self, "_on_hidden")
	project_button.connect("pressed", self, "_on_project_pressed", [project_button])
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
	var project = BuildingProject.new()
	project.building = key
	var project_def = BuildingDefinitions.building_defs[key]
	var building_index = BuildingDefinitions.building_types.find(key)
	var grid_tile = tile
	
	#tilemap_buildings.set_cell(grid_tile.tilemap_x, grid_tile.tilemap_y, building_index)
	project.remaining_industry = project_def.cost
	project.position = Vector2(grid_tile.tilemap_x, grid_tile.tilemap_y)
	project.type = type
	
	currentPlanet.colony.start_surface_building(project)
	project_display.set_project(currentPlanet)
	surface_project_sprite.set_project(tilemap_buildings, currentPlanet.colony.project)
	currentPlanet.colony.refresh()
	# TODO: may be obsolete
	project_grid.clear_buttons()
	PlanetMap.new().get_tilemap_from_planet(currentPlanet, tilemap_cells, tilemap_buildings)
	_notify_displays()
	popup.hide()

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
	pass

func generate_planet_display(planet):
	planet_sprite.set_planet(planet)
	PlanetMap.new().get_tilemap_from_planet(planet, tilemap_cells, tilemap_buildings)
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
		surface_project_sprite.update_progress(currentPlanet.colony.project)
	pass
	
func _on_hidden():
	surface_cursor.hide()

func _process(delta):
	pass

func _input(event):
	# TODO: when there is already a project picked, the behavior changes
	# fields that can't be built on don't react to the cursor
	if not is_visible():
		return
	if popup.is_visible():
		return
	if event.type == InputEvent.MOUSE_MOTION and currentPlanet != null:
		var relative_mouse_pos = tilemap_cells.get_local_mouse_pos()
		var tilemap_cells_pos = tilemap_cells.world_to_map(relative_mouse_pos)
		var cell = tilemap_cells.get_cell(tilemap_cells_pos.x, tilemap_cells_pos.y)
		if cell != -1:
			surface_cursor.set_pos(tilemap_cells.map_to_world(tilemap_cells_pos))
			surface_cursor.show()
		else:
			if surface_cursor.is_visible():
				surface_cursor.hide()
				
	if event.type == InputEvent.MOUSE_BUTTON and currentPlanet != null:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var relative_mouse_pos = tilemap_cells.get_local_mouse_pos()
			var tilemap_cells_pos = tilemap_cells.world_to_map(relative_mouse_pos)
			# ensure a square on the grid was clicked
			# option a: constrain to grid size
			#if tilemap_cells_pos.x < 0 or tilemap_cells_pos.y < 0 or tilemap_cells_pos.x >= currentPlanet.grid.size() or tilemap_cells_pos.y >= currentPlanet.grid.size():
			#	return
			# option b: only return if cell != -1
			var cell = tilemap_cells.get_cell(tilemap_cells_pos.x, tilemap_cells_pos.y)
			if cell != -1:
				var tile_under_mouse = currentPlanet.grid[tilemap_cells_pos.x][tilemap_cells_pos.y]
				var building_under_mouse = currentPlanet.buildings[tilemap_cells_pos.x][tilemap_cells_pos.y]
				if tile_under_mouse.get_tile_type() != null or building_under_mouse.type != null:
					if building_under_mouse.type != null:
						var text = "%s on %s square" % [building_under_mouse.building_name, tile_under_mouse.get_tile_type().capitalize()]
						# TODO: Normal behaviour is a popup that allows abandon or automate
						var buildings = project_grid.get_projects_for_surface(currentPlanet, tile_under_mouse, building_under_mouse)
						var textbut = project_grid.get_sprites_for_projects(buildings, tile_under_mouse)
						for tb in textbut:
							tb.connect("project_picked", self, "_on_project_picked")
						project_grid.set_buttons_on_container(textbut)
						#text += "\n%s" % str(buildings)
						popup.set_text(text)
						popup.popup_centered_ratio()
						#print(text)
					else:
						var text = "%s square, score: %02d" % [tile_under_mouse.get_tile_type().capitalize(), tile_under_mouse.score]
						if tile_under_mouse.buildable:
							var buildings = project_grid.get_projects_for_surface(currentPlanet, tile_under_mouse, building_under_mouse)
							var textbut = project_grid.get_sprites_for_projects(buildings, tile_under_mouse)
							for tb in textbut:
								tb.connect("project_picked", self, "_on_project_picked")
							project_grid.set_buttons_on_container(textbut)
							#text += "\n%s" % str(buildings)
						else:
							project_grid.clear_buttons()
						popup.set_text(text)
						popup.popup_centered_ratio()
						#print(thingo)
			#print(tilemap_cells_pos)
			#var cell = tilemap_cells.get_cell(tilemap_cells_pos.x, tilemap_cells_pos.y)
	pass
