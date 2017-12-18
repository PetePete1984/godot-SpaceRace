extends Reference

var project = null
var project_queue = []

var self_managed = false

var name = ""
var owner = null
var home = false

var planet = null

var industry = 0
var research = 0
var prosperity = 0

var adjusted_industry = 0
var adjusted_research = 0
var adjusted_prosperity = 0

var growth_bombed = false

var remaining_growth = 50

var unique_buildings = []

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
	if project != null:
		# remove building in progress if applicable
		var old_x = project.position.x
		var old_y = project.position.y
		
		var old_building = planet.buildings[old_x][old_y]
		if old_building.type != null:
			old_building.reset()
			
		# TODO: free the old worker?
		
		project = null
	
	var x = new_project.position.x
	var y = new_project.position.y
	# get the building tile
	var building = planet.buildings[x][y]
	# check if there's an active building on the tile
	if building.active:
	# if yes, deactivate it
		# if the project isn't automation, replace the building
		if not new_project.building == "automation":
			building.active = false
	# (but if the project is automation, keep it active)
	
	# then just reconfigure the building tile
	building.automated = false
	building.type = BuildingDefinitions.building_defs[new_project.building]
	building.building_name = building.type.building_name
	project = new_project
	pass

func finish_project():
	var building = planet.buildings[project.position.x][project.position.y]
	# finish the project by activating or automating the building
	if project.building == "automation":
		# zero out actually used pop
		# TODO: might be unnecessary because refresh uses the definition
		building.used_pop = 0
		building.automated = true
	if not building.active:
		building.active = true
		
	# special case for terraforming: reset the building
	if project.building == "terraforming":
		var cell = planet.grid[project.position.x][project.position.y]
		cell.tiletype = "white"
		building.reset()
		
	# empty the project
	project = null
	# TODO: use the next in queue
	refresh()
	pass
	
func refresh():
	var buildings = planet.buildings
	var grid = planet.grid
	
	var total_ind = 0
	var total_res = 0
	var total_prosp = 0
	var extra_slots = 0
	var working_pop = 0

	var building_types = []
	
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
					if not building.type.type in building_types:
						building_types.append(building.type.type)
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
	
	industry = total_ind
	research = total_res
	prosperity = total_prosp
	
	# TODO: if scientific takeover etc
	
	if "internet" in building_types:
		adjusted_research = int(floor(research * 1.5))
	else:
		adjusted_research = research
		
	if "hyperpower_plant" in building_types:
		adjusted_industry = int(pow(industry, 0.85) * 1.4)
	else:
		adjusted_industry = int(round(pow(industry, 0.85)))
	
	var pop = planet.population.alive
	# TODO: Find the correct formula
	if "fertilization_plant" in building_types:
		adjusted_prosperity = int(round(pow(prosperity, 0.85) * 1.4 - round(pow(0.4 * pop, 0.85)))) + 1
	else:
		adjusted_prosperity = int(round(pow(prosperity, 0.85) - round(pow(0.4 * pop, 0.85)))) + 1
	pass
	
	if growth_bombed == true:
		extra_slots += 10
	
	planet.population.work = working_pop
	planet.population.idle = planet.population.alive - working_pop
	planet.population.slots = planet.base_population + extra_slots
	planet.population.free = planet.population.slots - planet.population.alive

	unique_buildings = building_types
