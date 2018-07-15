# TODO: use inst2dict
var GameState = preload("res://Scripts/Model/GameState.gd")

# MARSHAL
func serialize_game_state(state):
	var json
	var dict = {
		turn = 0,
		galaxy = {},
		races = {},
		human_player = "",
		galaxy_settings = {}
	}
	# serialize all sub-objects into dictionaries
	dict.turn = state.turn
	dict.galaxy = serialize_galaxy(state.galaxy)
	
	dict.races = serialize_races(state.races)
	dict.human_player = state.human_player.race.type

	for option in state.galaxy_settings:
		dict.galaxy_settings[option] = state.galaxy_settings[option]
	
	# serialize dictionary to json
	json = dict.to_json()
	return json

func serialize_galaxy(galaxy):
	var result = {}
	
	result.systems = serialize_systems(galaxy.systems)
	result.lanes = serialize_lanes(galaxy.lanes)
	return result
	
func serialize_systems(systems):
	var result = {}
	for s in systems:
		result[s] = serialize_system(systems[s])
	return result
	pass
	
func serialize_system(system):
	var result = {
		"planets": {}
	}
	for p in system.planets:
		result.planets[p] = serialize_planet(system.planets[p])
	
	result.system_name = system.system_name
	result.star_type = system.star_type
	
	return result
	
func serialize_planet(planet):
	var result = {}
	# TODO: race id
	result.owner = planet.owner.race.type
	if planet.colony != null:
		result.colony = serialize_colony(planet.colony)
	else:
		result.colony = null
	
	result.system = planet.system.system_name
	result.position = planet.position
	result.planet_name = planet.planet_name
	result.size = planet.size
	result.type = planet.type
	result.base_population = planet.base_population
	result.growth_bombed = planet.growth_bombed
	result.grid = serialize_grid(planet.grid)
	result.buildings = serialize_buildings(planet.buildings)
	result.orbitals = serialize_orbitals(planet.orbitals)
	result.population = {}
	for p in planet.population:
		result.population[p] = planet.population[p]
	return result
	
func serialize_grid(grid):
	var result = []
	for x in grid:
		result.append([])
		for y in grid[x]:
			var tile = grid[x][y]
			# TODO: could be an array
			var dict = {
				tiletype = tile.tiletype,
				buildable = tile.buildable,
				tilemap_x = tile.tilemap_x,
				tilemap_y = tile.tilemap_y
			}
			result[x].append(dict)
	return result

func serialize_buildings(buildings):
	var result = []
	for x in buildings:
		result.append([])
		for y in buildings[x]:
			var tile = buildings[x][y]
			var dict = {
				type = tile.type.type,
				automated = tile.automated,
				active = tile.active,
				tilemap_x = tile.tilemap_x,
				tilemap_y = tile.tilemap_y,
				used_pop = tile.used_pop
			}
			result[x].append(dict)
	return result
	
func serialize_orbitals(orbitals):
	var result = []
	for x in orbitals:
		result.append([])
		for y in orbitals[x]:
			var tile = orbitals[x][y]
			var dict = {
				# TODO: serialize orbitals
			}
	return result

func serialize_colony(colony):
	var result = {}
	result.project = serialize_project(colony.project)
	result.self_managed = colony.self_managed
	result.colony_name = colony.colony_name
	result.owner = colony.owner.race.type
	result.home = colony.home
	# TODO: find a scheme that matches colonies to planets, name might be enough for now (although colonies can be renamed); might end up using array indices if I swap everything to arrays
	result.planet = colony.planet.planet_name
	# planetary stats are derived from buildings, so they don't need to be serialized
	result.remaining_growth = colony.remaining_growth
	return result

func serialize_project(project):
	pass

func serialize_lanes(lanes):
	pass

func serialize_lane(lane):
	pass

func serialize_research(research):
	pass

func serialize_races(races):
	# these need to store all data including special ability timers etc
	pass

func serialize_race(race):
	pass

# UNMARSHAL
func unserialize_game_state(json):
	var game_state
	# unserialize json to big dictionary
	# use sub-dictionaries' contents to overwrite instances of generated default objects
	# rebuild game_state from bottom to top
	return game_state
	pass