# responsible for changing or updating colony state

const BuildingProject = preload("res://Scripts/Model/BuildingProject.gd")
const BuildingRules = preload("res://Scripts/BuildingRules.gd")
const OrbitalProject = preload("res://Scripts/Model/OrbitalProject.gd")
const TechProject = preload("res://Scripts/Model/TechProject.gd")
const Planetmap = preload("res://Scripts/Planetmap.gd")

static func start_colony_project(colony, project_key, type, position):
	var planet = colony.planet
	var player = planet.owner
	var grid = planet.grid
	var buildings = planet.buildings
	var orbitals = planet.orbitals

	if type == "Surface":
		var project = BuildingProject.new()
		var project_definition = BuildingDefinitions.building_defs[project_key]
		project.project = project_key

		project.remaining_industry = project_definition.cost
		project.position = position # Vector2
		project.type = type # Surface, Orbital, Tech

		start_surface_building(colony, project)
		update_colony_stats(colony)
	elif type == "Orbital":
		var project = OrbitalProject.new()
		var project_definition = OrbitalDefinitions.orbital_defs[project_key]
		project.project = project_key
		project.remaining_industry = project_definition.cost
		project.position = position
		project.type = type

		start_orbital_building(colony, project)
		update_colony_stats(colony)
	pass

static func cancel_any_project(colony):
	if colony.project != null:
		if colony.project extends BuildingProject:
			var old_x = colony.project.position.x
			var old_y = colony.project.position.y

			var old_building = colony.planet.buildings[old_x][old_y]
			if old_building.type != null:
				old_building.reset()
		elif colony.project extends OrbitalProject:
			var old_x = colony.project.position.x
			var old_y = colony.project.position.y

			var old_orbital = colony.planet.orbitals[old_x][old_y]
			if old_orbital.type != null:
				old_orbital.reset()
			# TODO: reset
		elif colony.project extends TechProject:
			# TODO: finish techproject cancel (should be simple, unless it's automation?)
			colony.project = null
			pass
		pass
	pass

static func start_surface_building(colony, new_project):
	#colony.start_surface_building(new_project)
	# cancel old project
	cancel_any_project(colony)
	# TODO: check for memory leaks, probably can't just null this
	# TODO: somehow I blocked myself elsewhere and can't switch projects unless it's on the same tile, probably population
	var planet = colony.planet

	var x = new_project.position.x
	var y = new_project.position.y
	# get the building tile
	var building = planet.buildings[x][y]
	# check if there's an active building on the tile
	# TODO: maybe null check building tile first
	if building.active:
	# if yes, deactivate it
		building.active = false
	
	# then just reconfigure the building tile
	building.automated = false
	building.type = BuildingDefinitions.building_defs[new_project.project]
	# TODO: see if this can be made obsolete
	building.building_name = building.type.building_name
	colony.project = new_project	

static func start_orbital_building(colony, new_project):
	cancel_any_project(colony)
	var x = new_project.position.x
	var y = new_project.position.y
	var orbital = colony.planet.orbitals[x][y]
	# TODO: maybe null check building tile first
	if orbital.active:
		if not new_project.project == "automation":
			orbital.active = false

	orbital.automated = false
	orbital.type = OrbitalDefinitions.orbital_defs[new_project.project]
	#orbital.orbital_name = orbital.type.orbital_name
	colony.project = new_project
	pass

static func finish_project(colony):
	var project = colony.project
	if project != null:
		var x = -1
		var y = -1
		if project.position != null:
			x = project.position.x
			y = project.position.y
		if project extends BuildingProject:
			var building = colony.planet.buildings[x][y]
			building.active = true

			# special case for terraforming: reset the building
			if project.project == "terraforming":
				var cell = colony.planet.grid[x][y]
				cell.tiletype = "white"
				building.reset()

			# special case for xeno dig: reset the building tile and trigger a random research completion
			# research is triggered in turnhandler
			if project.project == "xeno_dig":
				building.reset()
			pass
		elif project extends OrbitalProject:
			var orbital = colony.planet.orbitals[x][y]
			# TODO: handle ships
			orbital.active = true
			pass
		elif project extends TechProject:
			if project.project == "automation":
				# find target type
				var target_grid = project.target_type
				# apply automation to target on correct grid
				if target_grid != null:
					if target_grid == "Surface":
						var building = colony.planet.buildings[x][y]
						building.used_pop = 0
						building.automated = true
					elif target_grid == "Orbital":
						var orbital = colony.planet.orbitals[x][y]
						orbital.used_pop = 0
						orbital.automated = true
				pass
			pass
		else:
			print("Unknown project type")
	project = null
	colony.project = null
	pass

static func update_colony_stats(colony):
	refresh_colony(colony)
	Planetmap.refresh_grids(colony.planet)

static func grow_population(colony):
	var previous_idle = colony.planet.population.idle
	
	var pop_growth = 0
	if "cloning_plant" in colony.unique_buildings:
		pop_growth = 2
	else:
		pop_growth = 1
	
	if pop_growth > 0:
		colony.planet.population.alive += pop_growth
		if colony.planet.population.alive >= colony.planet.population.slots:
			colony.planet.population.alive = colony.planet.population.slots
	
	colony.remaining_growth = 50
	refresh_colony(colony)
	return previous_idle

static func refresh_colony(colony):
	var planet = colony.planet
	var buildings = planet.buildings
	var grid = planet.grid
	var orbitals = planet.orbitals
	
	var total_ind = 0
	var total_res = 0
	var total_prosp = 0
	var extra_slots = 0
	var working_pop = 0

	var existing_building_types = []
	var existing_orbital_types = []

	# check buildings first
	for x in range(buildings.size()):
		for y in range(buildings[x].size()):
			var cell = grid[x][y]
			var building = buildings[x][y]
			var ind = 0
			var res = 0
			var prosp = 0
			
			if building.type != null:
				var def = building.type
				if building.active:
					if not building.type.type in existing_building_types:
						existing_building_types.append(building.type.type)

					if def.industry > 0:
						ind += def.industry
						if cell.tiletype == "red":
							ind += 1
	
					if def.research > 0:
						res += def.research
						if cell.tiletype == "blue":
							res += 1
	
					if def.prosperity > 0:
						prosp += def.prosperity
						if cell.tiletype == "green":
							prosp += 1
							
					if def.provided_pop > 0:
						extra_slots += def.provided_pop
						
				if def.used_pop > 0:
					if not building.automated:
						working_pop += def.used_pop
			
			total_ind += ind
			total_res += res
			total_prosp += prosp

	for x in range(orbitals.size()):
		for y in range(orbitals[x].size()):
			var orbital = orbitals[x][y]
			var ind = 0

			if orbital.type != null:
				var def = orbital.type
				if orbital.active:
					if not orbital.type.type in existing_orbital_types:
						existing_orbital_types.append(orbital.type.type)
					if def.industry > 0:
						ind += def.industry
				
				if def.used_pop > 0:
					if not orbital.automated:
						working_pop += def.used_pop
			
			total_ind += ind
	
	colony.industry = total_ind
	colony.research = total_res
	colony.prosperity = total_prosp

	var internet = "internet" in existing_building_types
	var hyperpower = "hyperpower_plant" in existing_building_types
	var fertilized = "fertilization_plant" in existing_building_types
	
	if internet:
		colony.adjusted_research = int(floor(colony.research * 1.5))
	else:
		colony.adjusted_research = colony.research
		
	if hyperpower:
		colony.adjusted_industry = int(pow(colony.industry, 0.85) * 1.4)
	else:
		colony.adjusted_industry = int(round(pow(colony.industry, 0.85)))
	
	var endless_party = false

	if colony.project != null:
		if colony.project extends TechProject:
			if colony.project.project == "scientist_takeover":
				if hyperpower:
					colony.adjusted_research += int(float(colony.industry) * 1.5 / 4)
				else:
					colony.adjusted_research += int(float(colony.industry / 4))
			elif colony.project.project == "endless_party":
				endless_party = true


	var pop = planet.population.alive
	# TODO: Find the correct formula
	var additional_prosperity = 0
	if endless_party:
		additional_prosperity = int(float(colony.adjusted_industry)/3)

	if fertilized:
		colony.adjusted_prosperity = int(round(pow(colony.prosperity, 0.85) * 1.4 + additional_prosperity - round(pow(0.4 * pop, 0.85)))) + 1
	else:
		colony.adjusted_prosperity = int(round(pow(colony.prosperity, 0.85) + additional_prosperity - round(pow(0.4 * pop, 0.85)))) + 1
	pass
	
	if planet.growth_bombed == true:
		extra_slots += 10
	
	planet.population.work = working_pop
	planet.population.idle = planet.population.alive - working_pop
	planet.population.slots = planet.base_population + extra_slots
	planet.population.free = planet.population.slots - planet.population.alive

	colony.unique_buildings = existing_building_types
	colony.unique_orbitals = existing_orbital_types
