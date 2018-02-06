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
	var path = "res://Images/Races/FlagsBW/raceflag.shp_%02d.png" % [race.index + 1]
	return get_texture(path)
	pass
	
func get_race_icon(player):
	var race = _type(player)
	var index = race.index
	var path = "res://Images/Races/Icons/smrace%02d/smrace%02d.shp_1.png" % [index, index]
	return get_texture(path)
	pass

func get_race_ring_neutral():
	var path = "res://Images/Races/Rings/racering.shp_8.png"
	return get_texture(path)
	
func get_home_planet(player):
	var race = _type(player)
	var index = race.index
	var path = "res://Images/Races/HomePlanets/smhome.shp_%02d.png" % [index + 1]
	return get_texture(path)
	pass
	
func get_star(system, small = false):
	var path = null
	var image_index = mapdefs.stars.find(system.star_type)
	if image_index != -1:
		if small:
			image_index = (image_index + 1) * 4
			path = "res://Images/Screens/Galaxy/Stars/cos_star.shp_%02d.png" % image_index
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
	# offset by +1 because images start at 1
	var size_index = mapdefs.planet_sizes.find(size) + 1
	if type_index != -1 and size_index != -1:
		var path = null
		if small == true:
			var small_planet_index = (type_index * mapdefs.planet_sizes.size()) + size_index
			path = "res://Images/Screens/Battle/Planets/planets.shp_%02d.png" % [small_planet_index]
		else:
			path = "res://Images/Planets/planal%02d/planal%02d.shp_%d.png" % [type_index, type_index, size_index]
		if path != null:
			return get_texture(path)
	else:
		print("TextureHandler: Normal Planet Texture not found for %s, %s" % [type, size])
		return null
	pass

# TODO: could also do a more clever function that just derives everything from a ship and a docked var
func get_ship(player, ship_size = "small", docked = false):
	var race = _type(player)
	var race_index = race.index
	# TODO: move elsewhere
	var sizes = ["small", "medium", "large", "enormous"]
	var ship_index = sizes.find(ship_size)
	if ship_index != -1:
		var path = null
		if docked == true:
			path = "res://Images//Screens//ShipDesign//Ships//dkship%02d//dkship%02d.shp_%d.png" % [race_index, race_index, ship_index + 1]
		else:
			path = "res://Images//Races//Ships//smship%02d//smship%02d.shp_%d.png" % [race_index, race_index, ship_index + 1]
		if path != null:
			return get_texture(path)
	else:
		print("TextureHander: Ship Texture not found for %s, %s, docked = %s") % [race, ship_size, str(docked)]

func get_ship_module(ship_module):
	var index = ShipModuleDefinitions.ship_module_defs[ship_module].index
	if index > 0:
		var path = "res://Images/Ship/Equipment/gizmos.shp_%02d.png" % [index]
		printt(ship_module, path)
		return get_texture(path)


func get_surface_building(building):
	var building_index = BuildingDefinitions.building_types.find(building)
	if building_index != -1:
		var path = "res://Images/Screens/Planet/Buildings/Surface/%02d_%s.png" % [building_index + 1, building]
		return get_texture(path)
	pass

func get_orbital_building(project, player = null):
	var def = OrbitalDefinitions.orbital_defs[project]
	if player != null and def.research_ship_size != null:
		# get medium ship texture for player
		return get_ship(player, def.research_ship_size)
	else:
		var project_index = OrbitalDefinitions.orbital_types.find(project)
		if project_index != -1:
			var path = "res://Images/Screens/Planet/Buildings/Orbital/%02d_%s.png" % [project_index + 1, project]
			return get_texture(path)
	
func get_research_icon(research):
	var resDef = ResearchDefinitions.research_defs[research]
	var path = "res://Images/Screens/Research/Research/restree.shp_%02d.png" % (resDef.index+1)
	return get_texture(path)
	pass
	
# research points display
func get_research(planet):
	return get_indexed_display("Research", planet.colony.adjusted_research)
	pass

func get_industry(planet):
	return get_indexed_display("Industry", planet.colony.adjusted_industry)
	pass

func get_prosperity(planet):
	return get_indexed_display("Prosperity", planet.colony.adjusted_prosperity)
	pass
	
func get_person(type, small = false):
	pass
	
func get_indexed_display(type, points):
	var index = -1
	if type == "Research" or type == "Industry":
		index = _lookup_index(points)
	elif type == "Prosperity":
		index = _flat_index(points)
	else:
		index = 0
		
	if index != -1:
		var path = "res://Images/Screens/Planet/%s/%02d.png" % [type, index]
		return get_texture(path)
	pass

func _lookup_index(points):
	var index = points
	if points < 0:
		index = 0
	elif points >= indexed_lookup.size():
		index = 20
	else:
		index = indexed_lookup[points]
	return index
	
func _flat_index(points):
	var index = points
	if points < 0:
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