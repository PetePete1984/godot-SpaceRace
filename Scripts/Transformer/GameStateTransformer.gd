extends Reference

func get_json_from_galaxy(galaxy):
	var result = {}
	
	result.systems = get_json_from_systems(galaxy.systems)
	return result
	pass
	
	
func get_json_from_systems(systems):
	var result = {}
	for s in systems:
		result[s] = get_json_from_system(systems[s])
	return result
	pass
	
func get_json_from_system(system):
	var result = {
		"planets": {}
	}
	for p in system.planets:
		result.planets[p] = get_json_from_planet(system.planets[p])
	result.system_name = system.system_name
	result.star_type = system.star_type
		
	return result
	pass
	
func get_json_from_planet(planet):
	var result = {
#	# player
#var owner
#
# System + 1234
#var planet_name
#
# size template
#var size = "enormous"
#
# type template
#var type = "cornucopia"
#
# both cell and building grids could just as well be dictionaries
# initial cell grid
#var grid = []
#
# buildings grid
#var buildings = []
#
# orbitals grid
#var orbitals = []
# var max_population
# var project
	}
	
	pass
	
func get_json_from_buildings():
	pass

func get_json_from_cells():
	pass
	
func get_json_from_orbitals():
	pass
	
func get_json_from_project():
	pass