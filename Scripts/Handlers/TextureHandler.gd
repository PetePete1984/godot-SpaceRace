# AutoLoad TextureHandler responsible for loading and caching textures requested by the rest of the game
# Keeps all paths to textures in one place
# Allows for switching out entire sets of textures
extends Node
# reference to Player class
var Player = preload("res://Scripts/Model/Player.gd")
var Race = preload("res://Scripts/Model/RaceDef.gd")

# texture cache
var cache = {}

# lookup table for industry and research points
const indexed_lookup = [0,1,1,2,2,3,3,4,4,5,
	5,6,6,6,7,7,7,8,8,9,
	9,9,10,10,10,11,11,11,12,12,
	12,13,13,13,14,14,14,15,15,15,
	15,16,16,16,17,17,17,17,18,18,
	18,19,19,19,19]

# TODO: allow loading a "texturepack" (JSON with base paths)

func get_texture(path):
	if cache.has(path):
		return cache[path]
	elif File.new().file_exists(path):
		var texture = load(path)
		cache[path] = texture
		return texture
	else:
		print("TextureHandler: File not found: %s" % path)
		return null

func get_race_flag(player):
	var race = _type(player)
	var path = "res://Images/Races/FlagsBW/raceflag.ascshp_%03d.png" % [race.index]
	return get_texture(path)
	
func get_race_icon(player, small = true):
	var race = _type(player)
	var index = race.index
	var path = null
	if small:
		path = "res://Images/Races/Icons/smrace%02d/smrace%02d.ascshp_000.png" % [index, index]
	else:
		path = "res://Images/Screens/RaceIntro/Races/lgrace%02d/lgrace%02d.ascshp_000.png" % [index, index]
	return get_texture(path)

func get_race_ring_neutral():
	var path = "res://Images/Races/Rings/racering.ascshp_007.png"
	return get_texture(path)
	
func get_home_planet(player):
	var race = _type(player)
	var index = race.index
	var path = "res://Images/Races/HomePlanets/smhome.ascshp_%03d.png" % [index]
	return get_texture(path)
	
func get_star(system, small = false):
	var path = null
	var image_index = mapdefs.stars.find(system.star_type)
	if image_index != -1:
		if small:
			image_index = image_index * 4 + 3 # offset by 3 to get 3, 7, 11 etc
			path = "res://Images/Screens/Galaxy/Stars/cos_star.ascshp_%03d.png" % image_index
		else:
			path = "res://Images/Screens/Battle/Suns/%02d_%s.png" % [image_index+1, system.star_type]
		
		if path != null:
			return get_texture(path)
		else:
			print("TextureHandler: Star Texture not found")
			return null
	else:
		print("TextureHandler: Star Texture not found for %s" % [system.star_type])
		return null
	
func get_planet(planet, small = false):
	var type = planet.type
	var type_index = mapdefs.planet_types.find(type)
	var size = planet.size
	var size_index = mapdefs.planet_sizes.find(size)
	if type_index != -1 and size_index != -1:
		var path = null
		if small == true:
			var small_planet_index = (type_index * mapdefs.planet_sizes.size()) + size_index
			path = "res://Images/Screens/Battle/Planets/planets.ascshp_%03d.png" % [small_planet_index]
		else:
			path = "res://Images/Planets/planal%02d/planal%02d.ascshp_%03d.png" % [type_index, type_index, size_index]
		if path != null:
			return get_texture(path)
	else:
		print("TextureHandler: Normal Planet Texture not found for %s, %s" % [type, size])
		return null
	pass

func get_starlane(lane):
	var path = "res://Images/Screens/Battle/Lanes/%s.png" % [lane.type]
	return get_texture(path)

# TODO: could also do a more clever function that just derives everything from a ship and a docked var
# needs to know if it's showing a ship on a planet, in space or in the research screen
func get_ship(player, ship_size = "small", docked = false):
	var race = _type(player)
	var race_index = race.index
	# TODO: move elsewhere
	var sizes = ["small", "medium", "large", "enormous"]
	var ship_index = sizes.find(ship_size)
	if ship_index != -1:
		var path = null
		if docked == true:
			path = "res://Images/Screens/ShipDesign/Ships/dkship%02d/dkship%02d.ascshp_%03d.png" % [race_index, race_index, ship_index]
		else:
			path = "res://Images/Races/Ships/smship%02d/smship%02d.ascshp_%03d.png" % [race_index, race_index, ship_index]
		if path != null:
			return get_texture(path)
	else:
		print("TextureHander: Ship Texture not found for %s, %s, docked = %s") % [race, ship_size, str(docked)]

func get_ship_for_planet(ship, sprite):
	var texture = get_ship(ship.owner, ship.size)
	sprite.set_texture(texture)
	if ShipDefinitions.drawing_scale_offset.has(ship.size):
		var offset_scale = ShipDefinitions.drawing_scale_offset[ship.size]
		var offset = Vector2(offset_scale.offset_planet[0], offset_scale.offset_planet[1])
		var scale = Vector2(offset_scale.scale_planet, offset_scale.scale_planet)
		sprite.set_offset(offset)
		sprite.set_scale(scale)

func get_ship_module(ship_module):
	# TODO: this is no longer the image index, maybe just offset by -1
	var index = ShipModuleDefinitions.ship_module_defs[ship_module].index - 1
	if index > -1:
		var path = "res://Images/Ship/Equipment/gizmos.ascshp_%03d.png" % [index]
		#printt(ship_module, path)
		return get_texture(path)

func get_surface_building(building):
	var building_index = BuildingDefinitions.building_types.find(building)
	if building_index != -1:
		var path = "res://Images/Screens/Planet/Buildings/Surface/%02d_%s.png" % [building_index + 1, building]
		return get_texture(path)
	pass

# TODO: implement ship graphics for ship building / refit / orbiting here or elsewhere
func get_orbital_building(project, player = null):
	if typeof(project) == TYPE_STRING:
		var def = OrbitalDefinitions.orbital_defs[project]
		if player != null and def.research_ship_size != null:
			# get medium ship texture for player, as this is the display for research results
			return get_ship(player, def.research_ship_size)
		else:
			var project_index = OrbitalDefinitions.orbital_types.find(project)
			if project_index != -1:
				var path = "res://Images/Screens/Planet/Buildings/Orbital/%02d_%s.png" % [project_index + 1, project]
				return get_texture(path)
	elif typeof(project) == TYPE_OBJECT:
		if "sub_type" in project and project.sub_type.begins_with("Ship"):
			# ship construction or refit project, load the actual ship sprite
			return get_ship(player, project.resulting_ship.size)
	pass

func get_tech_project(project):
	var index = TechProjectDefinitions.project_types.find(project)
	if index != -1:
		var path = "res://Images/Screens/Planet/Buildings/Tech/%02d_%s.png" % [index + 1, project]

func get_research_icon(research):
	var resDef = ResearchDefinitions.research_defs[research]
	var path = "res://Images/Screens/Research/Research/restree.ascshp_%03d.png" % (resDef.index)
	#prints("loading", path)
	return get_texture(path)

func get_research_icon_by_index(index):
	var path = "res://Images/Screens/Research/Research/restree.ascshp_%03d.png" % (index)
	#prints("loading", path)
	return get_texture(path)

func get_research_ring(type):
	var path = "res://Images/Screens/Research/Rings/%s.png" % type
	return get_texture(path)
	
# research points display
func get_research(planet):
	return get_indexed_display("Research", planet.colony.adjusted_research)

func get_industry(planet):
	return get_indexed_display("Industry", planet.colony.adjusted_industry)

func get_prosperity(planet):
	return get_indexed_display("Prosperity", planet.colony.adjusted_prosperity)
	
# for population displays
func get_person(type, small = false):
	pass
	
func get_turn_digit(digit):
	var path = "res://Images/Screens/Galaxy/Layout/Numbers/%d.png" % digit
	return get_texture(path)

func get_indexed_display(type, points):
	var index = -1
	if type == "Research" or type == "Industry":
		index = _adjusted_index(points)
	elif type == "Prosperity":
		index = _flat_index(points)
	else:
		index = 0
		
	if index != -1:
		var path = "res://Images/Screens/Planet/%s/%02d.png" % [type, index]
		return get_texture(path)
	pass

func _adjusted_index(points):
	var index = points
	if points <= 0:
		index = 0
	else:
		index = int(floor(pow(points, 0.75)))
	if index > 20:
		index = 20
	return index
	
func _flat_index(points):
	var index = points
	if points <= 0:
		index = 0
	elif points > 20:
		index = 20
	return index
	
func _type(player):
	if typeof(player) == TYPE_STRING:
		return RaceDefinitions.race[player]
	elif player extends Player:
		return player.race
	elif player extends Race:
		return player
	else:
		return RaceDefinitions.race[player]