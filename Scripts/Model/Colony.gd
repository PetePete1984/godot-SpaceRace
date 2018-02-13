extends Reference

# TODO: move to colonymanager
var TechProject = preload("res://Scripts/Model/TechProject.gd")

var project = null
var project_queue = []

var self_managed = false

var colony_name = ""
var owner = null
var home = false

var planet = null

var industry = 0
var research = 0
var prosperity = 0

var adjusted_industry = 0
var adjusted_research = 0
var adjusted_prosperity = 0

var remaining_growth = 50

var unique_buildings = []
var unique_orbitals = []

func get_population():
	return planet.population

func grow_population():
	var previous_idle = planet.population.idle
	
	var pop_growth = 0
	if "cloning_plant" in unique_buildings:
		pop_growth = 2
	else:
		pop_growth = 1
	
	if pop_growth > 0:
		planet.population.alive += pop_growth
		if planet.population.alive >= planet.population.slots:
			planet.population.alive = planet.population.slots
	
	remaining_growth = 50
	refresh()
	return previous_idle
	pass

func start_surface_building(new_project):
	# cancel old project
	# TODO: check for memory leaks, probably can't just null this
	# TODO: somehow I blocked myself elsewhere and can't switch projects unless it's on the same tile
	if project != null:
		# remove building in progress if applicable
		var old_x = project.position.x
		var old_y = project.position.y
		
		var old_building = planet.buildings[old_x][old_y]
		if old_building.type != null:
			old_building.reset()
			
		# TODO: free the old worker? should be done by update stats?
		
		project = null
	
	var x = new_project.position.x
	var y = new_project.position.y
	# get the building tile
	var building = planet.buildings[x][y]
	# check if there's an active building on the tile
	# TODO: maybe null check building tile first
	if building.active:
	# if yes, deactivate it
		# if the project isn't automation, replace the building
		if not new_project.project == "automation":
			building.active = false
	# (but if the project is automation, keep it active)
	
	# then just reconfigure the building tile
	building.automated = false
	building.type = BuildingDefinitions.building_defs[new_project.project]
	# TODO: see if this can be made obsolete
	building.building_name = building.type.building_name
	project = new_project
	pass

func finish_project():
	var building = planet.buildings[project.position.x][project.position.y]
	# finish the project by activating or automating the building
	if project.project == "automation":
		# zero out actually used pop
		# TODO: might be unnecessary because refresh uses the definition
		building.used_pop = 0
		building.automated = true
	if not building.active:
		building.active = true
		
	# special case for terraforming: reset the building
	if project.project == "terraforming":
		var cell = planet.grid[project.position.x][project.position.y]
		cell.tiletype = "white"
		building.reset()
	# special case for xeno dig: reset the building tile and trigger a random research completion
	# research is triggered in turnhandler
	if project.project == "xeno_dig":
		building.reset()
		
	# empty the project
	project = null
	# TODO: use the next in queue
	#refresh()
	pass
	
func refresh():
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
	
	industry = total_ind
	research = total_res
	prosperity = total_prosp

	var internet = "internet" in existing_building_types
	var hyperpower = "hyperpower_plant" in existing_building_types
	var fertilized = "fertilization_plant" in existing_building_types
	
	if internet:
		adjusted_research = int(floor(research * 1.5))
	else:
		adjusted_research = research
		
	if hyperpower:
		adjusted_industry = int(pow(industry, 0.85) * 1.4)
	else:
		adjusted_industry = int(round(pow(industry, 0.85)))
	
	var endless_party = false

	if project != null:
		if project extends TechProject:
			if project.project == "scientist_takeover":
				if hyperpower:
					adjusted_research += int(float(industry) * 1.5 / 4)
				else:
					adjusted_research += int(float(industry / 4))
			elif project.project == "endless_party":
				endless_party = true


	var pop = planet.population.alive
	# TODO: Find the correct formula
	var additional_prosperity = 0
	if endless_party:
		additional_prosperity = int(float(adjusted_industry)/3)

	if fertilized:
		adjusted_prosperity = int(round(pow(prosperity, 0.85) * 1.4 + additional_prosperity - round(pow(0.4 * pop, 0.85)))) + 1
	else:
		adjusted_prosperity = int(round(pow(prosperity, 0.85) + additional_prosperity - round(pow(0.4 * pop, 0.85)))) + 1
	pass
	
	if planet.growth_bombed == true:
		extra_slots += 10
	
	planet.population.work = working_pop
	planet.population.idle = planet.population.alive - working_pop
	planet.population.slots = planet.base_population + extra_slots
	planet.population.free = planet.population.slots - planet.population.alive

	unique_buildings = existing_building_types
	unique_orbitals = existing_orbital_types
