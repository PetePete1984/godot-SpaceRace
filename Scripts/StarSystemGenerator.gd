# Star System Generator
extends Reference

var StarSystem = preload("res://Scripts/Model/StarSystem.gd")
var PlanetGenerator = preload("res://Scripts/PlanetGenerator.gd")

var used_star_names

func generate_star(i = 0):
	var sys = StarSystem.new()
	var star = Utils.rand_pick_from_array(mapdefs.stars)
	sys.star_type = star
	if used_star_names != null:
		sys.system_name = Utils.rand_pick_from_array_no_dupes(mapdefs.system_names, used_star_names)
		used_star_names.append(sys.system_name)
	else:
		sys.system_name = "%d - %s - %s" % [i, star, sys.system_name]
	return sys
	pass

func generate_planets(system):
	var plan_gen = PlanetGenerator.new()
	var num_planets = (randi() % mapdefs.max_planets) + mapdefs.min_planets
	#print("planets: %02d" % num_planets)
	for p in range(num_planets):
		var planet = plan_gen.generate_planet()
		planet.planet_name = "%s %02d" % [system.system_name, p]
		planet.system = system
		var plan_pos = Utils.rand_v3_in_unit_sphere(10)
		# FIXME: planet y pos has to be set some other way
		plan_pos.y = 3
		if not system.planets.has(plan_pos):
			system.planets[plan_pos] = planet
	pass

func generate_system(i = 0):
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