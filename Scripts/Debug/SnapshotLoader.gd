const ColonyManager = preload("res://Scripts/Manager/ColonyManager.gd")
const ColonyController = preload("res://Scripts/Controller/ColonyController.gd")
const ShipFactory = preload("res://Scripts/Factories/ShipFactory.gd")

static func debug_snapshot(player, planets):
	set_up_early_game(player, planets)
	# set_up_colonizer(player, planets)
	set_up_ship_debug(player, planets)

static func set_up_early_game(player, planets):
	print("setting up early game")
	# provide a bunch of early research
	var research_to_complete = ["orbital_structures", "xenobiology", "environmental_encapsulation", "interplanetary_exploration", "tonklin_diary", "spacetime_surfing"]
	for project in research_to_complete:
		ResearchHandler.instant_research(player, project)

	for planet in planets:
		# increase each colony's population to a reasonable level
		var size = planet.size
		var fields = mapdefs.planet_size[size].fields
		var half_cap = floor(fields/2.0)
		if planet.population.slots < half_cap:
			planet.base_population = half_cap + 10
			planet.population.slots = half_cap
			planet.population.free = planet.population.slots - planet.population.alive
		
		# auto-build a few buildings
		for i in range(planet.population.free):
			var build_next = ColonyManager.manage(planet.colony)
			if build_next != null:
				if build_next.project != null:
					ColonyController.start_project(planet.colony, build_next.square, [build_next.project, build_next.type])
					ColonyController.finish_project(planet.colony)
					ColonyController.grow_population(planet.colony)

		# TODO: build a shipyard / handle shipyard building in colonymanager
		ColonyController.start_project(planet.colony, Vector2(0, 0), ["shipyard", "Orbital"])
		ColonyController.finish_project(planet.colony)
		ColonyController.grow_population(planet.colony)

		# create new fresh pops
		ColonyController.grow_population(planet.colony)
		ColonyController.grow_population(planet.colony)

static func set_up_colonizer(player, planets, finish = true):
	print("setting up colonizers on all planets")
	
	var ship_design = ShipFactory.get_design_from_template(ShipFactory.get_template_from_blueprint(ShipFactory.ShipTemplate.prefabs.medium_colony_double_speed, player))

	for planet in planets:
		var colony = planet.colony
		# var position = ColonyController.get_free_orbital()
		var position = Vector2(0, 1)
		if position != null:
			ColonyController.start_ship_project(colony, ship_design, position)
			if finish:
				ColonyController.finish_project(planet.colony)
				ColonyController.grow_population(planet.colony)
	pass

static func set_up_warship():
	pass

static func set_up_module_spammer():
	pass

static func set_up_mid_game():
	pass

static func set_up_end_game():
	pass

static func set_up_ship_debug(player, planets, large = true, enormous = true, finish = true):
	print("setting up large and/or enormous ships on all planets")
	
	var ship_large = ShipFactory.get_design_from_template(ShipFactory.get_template_from_blueprint(ShipFactory.ShipTemplate.prefabs.large_debug, player))
	var ship_enormous = ShipFactory.get_design_from_template(ShipFactory.get_template_from_blueprint(ShipFactory.ShipTemplate.prefabs.enormous_debug, player))

	for planet in planets:
		var colony = planet.colony
		# var position = ColonyController.get_free_orbital()
		if large:
			var position = Vector2(0, 2)
			if position != null:
				ColonyController.start_ship_project(colony, ship_large, position)
				if finish:
					ColonyController.finish_project(planet.colony)
					ColonyController.grow_population(planet.colony)

		if enormous:
			if large and not finish:
				ColonyController.finish_project(planet.colony)
				ColonyController.grow_population(planet.colony)
			var position = Vector2(1, 2)
			if position != null:
				ColonyController.start_ship_project(colony, ship_enormous, position)
				if finish:
					ColonyController.finish_project(planet.colony)
					ColonyController.grow_population(planet.colony)
	

	pass