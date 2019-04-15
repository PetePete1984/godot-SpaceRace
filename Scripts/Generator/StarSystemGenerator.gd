# Star System Generator
extends Reference

const StarSystem = preload("res://Scripts/Model/StarSystem.gd")
const PlanetGenerator = preload("res://Scripts/Generator/PlanetGenerator.gd")

static func generate_star(used_star_names, i = 0):
	var sys = StarSystem.new()
	var star = Utils.rand_pick_from_array(mapdefs.stars)
	sys.star_type = star
	if used_star_names != null:
		sys.system_name = Utils.rand_pick_from_array_no_dupes(mapdefs.system_names, used_star_names)
		used_star_names.append(sys.system_name)
	else:
		sys.system_name = "%d - %s - %s" % [i, star, sys.system_name]
	sys.index = i
	return sys
	pass

static func generate_planets(system):
	# TODO: keep planets a minimum distance away from the sun
	# TODO: give planets an index
	var num_planets = (randi() % mapdefs.max_planets) + mapdefs.min_planets
	var used_positions = []
	#print("planets: %02d" % num_planets)
	for p in range(num_planets):
		var planet = PlanetGenerator.generate_planet()
		planet.planet_name = "%s %02d" % [system.system_name, p]
		planet.system = system
		planet.index = p
		# TODO: since Y is fixed, change to v2 in unit circle
		var plan_pos = Utils.rand_v3_in_unit_sphere(10)
		# FIXME: planet y pos has to be set some other way
		plan_pos.y = mapdefs.system_default_y
		while plan_pos in used_positions:
			plan_pos = Utils.rand_v3_in_unit_sphere(10)
			# FIXME: planet y pos has to be set some other way
			plan_pos.y = mapdefs.system_default_y
		
		planet.position = plan_pos
		system.planets.append(planet)
		used_positions.append(plan_pos)
	pass

static func generate_system(used_star_names, i = 0):
	var sys = StarSystem.new()
	var star = Utils.rand_pick_from_array(mapdefs.stars)
	sys.star_type = star
	if used_star_names != null:
		sys.system_name = Utils.rand_pick_from_array_no_dupes(mapdefs.system_names, used_star_names)
		used_star_names.append(sys.system_name)
	else:
		sys.system_name = "%d - %s - %s" % [i, star, sys.system_name]
	
	# TODO: split off so the galaxy settings screen can generate empty systems
	generate_planets(sys)
	return sys
	pass