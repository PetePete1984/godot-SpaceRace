# Colony Manager

# imports for type checking
const BuildingProject = preload("res://Scripts/Model/BuildingProject.gd")
const BuildingRules = preload("res://Scripts/BuildingRules.gd")
const OrbitalProject = preload("res://Scripts/Model/OrbitalProject.gd")
const TechProject = preload("res://Scripts/Model/TechProject.gd")
const Planetmap = preload("res://Scripts/Planetmap.gd")

# class to auto-manage a colony?

# TODO: build candidate lists from tags in building definitions
# TODO: maybe adopt a more GOAP-like approach
# ie simplify "need industry" => "pick highest available industry yield"
# an advanced version would also take industry cost efficiency into account (ie agriplot is usually more efficient than hydroponifer)
var candidate_lists

static func manage(colony):
	# TODO: maybe path to xeno ruins along the way
	# standard progression
	# early game:
		# build up industry
		# build up prosperity
		# build 2-3 labs
	# space travel and colonizer available:
		# build industry until 15-20
		# build shipyard
		# build medium colony ship
		# immediately build second colony ship
	# colony ships are travelling:
		# keep building industry
	# mid-game (research campus available):
		# never build laboratories again, instead shift the "build anything research" threshold
	# always keep an eye on:
		# prosperity > 0 if free > 0
		# habitat-style buildings if free < 2 and slots available
	
	# bonus considerations:
		# planets that have filled all planet slots don't need pure prosperity buildings anymore
		
	var project_candidate = null
	var project_running = colony.project
	var party_project = false
	var keep_waiting = true
	
	if project_running != null:
		# converter projects are run because nothing was available before
		if project_running extends TechProject:
			# which in turn enables a re-check
			# TODO: delay re-check if waiting for a reason
			keep_waiting = false
	else:
		keep_waiting = false
	
	if keep_waiting == false:
		# count planet slots
		var buildable_squares = get_buildable_squares(colony)
		var all_squares = get_all_unused_squares(colony)
		var num_buildable_squares = buildable_squares.keys().size()
		var num_all_squares = all_squares.keys().size()
		
		var all_reachable_are_black = true
		for coord in buildable_squares:
			var square = buildable_squares[coord]
			all_reachable_are_black = all_reachable_are_black and square.tiletype == "black"
		
		var all_unused_are_black = true
		for coord in all_squares:
			var square = all_squares[coord]
			all_unused_are_black = all_unused_are_black and square.tiletype == "black"
		
		var prosperity = colony.adjusted_prosperity
		var industry = colony.adjusted_industry
		var research = colony.adjusted_research
		var global_research = colony.owner.total_research
		
		var idle_pop = colony.planet.population.idle
		var free_pop = colony.planet.population.free
		
		var available_buildings
		var available_projects
		var available_orbitals
		
		var terraforming_available = BuildingRules.project_available(colony.owner, "terraforming")
		# FIXME: make it so
		var growth_bomb_available = false
		var growth_bomb_used = colony.planet.growth_bombed == true
		var automation_available = false
		var hyperpower_available = BuildingRules.project_available(colony.owner, "hyperpower_plant")
		var hyperpower_exists = "hyperpower_plant" in colony.unique_buildings
		var internet_available = BuildingRules.project_available(colony.owner, "internet")
		var internet_exists = "internet" in colony.unique_buildings
		
		if num_all_squares > 0:
			if num_buildable_squares > 0:
				if prosperity > 0:
					if idle_pop > 0:
						if all_reachable_are_black:
							# FIXME: extract as "handle_black_square"
							if colony.owner.race.type == "orfa":
								pick_a_white_square(colony)
							else:
								if terraforming_available:
									project_candidate = "terraforming"
								else:
									if all_unused_are_black:
										# wait for terraforming
										printt(colony.planet.planet_name, "waiting for terraforming")
										keep_waiting = true
									else:
										# TODO: pathfind to better squares?
										project_candidate = "transport_tubes"
						else:
							# non-black squares available
							# FIXME: this gets stuck in either 0 free / 1 idle (without the or) or 0 free / 0 idle (with the or)
							if free_pop > 0 or num_all_squares > free_pop:
								if free_pop < 2:
									#printt(colony.planet.planet_name, num_all_squares)
									pass
								if free_pop < 2 and num_all_squares > free_pop:
									if growth_bomb_available:
										if growth_bomb_used:
											if automation_available:
												automate_something(colony)
											else:
												project_candidate = "habitation"
										else:
											project_candidate = "growth_bomb"
									else:
										if automation_available:
											automate_something(colony)
										else:
											project_candidate = "habitation"
								else:
									var free_red_square = null
									var free_blue_square = null
									var free_green_square = null
									var free_white_square = null
									var free_black_square = null
									for b in buildable_squares:
										var square = buildable_squares[b]
										if square.tiletype == "red" and free_red_square == null:
											free_red_square = true
										elif square.tiletype == "blue" and free_blue_square == null:
											free_blue_square = true
										elif square.tiletype == "green" and free_green_square == null:
											free_green_square = true
										elif square.tiletype == "white" and free_white_square == null:
											free_white_square = true
										elif square.tiletype == "black" and free_black_square == null:
											free_black_square = true
									
									if prosperity < 2:
										project_candidate = "prosperity"
									elif industry < 4:
										project_candidate = "industry"
									elif free_red_square:
										if industry >= 4 and global_research < 5 and free_blue_square:
											project_candidate = "research"
										else:
											project_candidate = "industry"
									elif free_blue_square:
										project_candidate = "research"
									elif free_green_square:
										project_candidate = "prosperity"
									elif free_white_square:
										# FIXME: apply some kind of global tech level
										# TODO: can this look more readable?
										# TODO: extract as "pick a white square" func
										if industry >= 4 and global_research >= 5:
											if industry >= 10:
												if hyperpower_available:
													if hyperpower_exists:
														if industry >= 25:
															if research >= 12:
																if internet_available:
																	if internet_exists:
																		project_candidate = "research"
																	else:
																		project_candidate = "internet"
																else:
																	project_candidate = "research"
															else:
																project_candidate = "research"
														else:
															project_candidate = "industry"
													else:
														project_candidate = "hyperpower_plant"
												else:
													project_candidate = "industry"
											else:
												project_candidate = "industry"
										else:
											project_candidate = "research"
										pass
									elif free_black_square:
										# FIXME: extract as "handle_black_square"
										if colony.owner.race.type == "orfa":
											pick_a_white_square(colony)
										else:
											if terraforming_available:
												project_candidate = "terraforming"
											else:
												if all_unused_are_black:
													# wait for terraforming
													printt(colony.planet.planet_name, "waiting for terraforming")
													keep_waiting = true
												else:
													# TODO: pathfind to better squares?
													project_candidate = "transport_tubes"
									pass
							else:
								print("free_pop is = 0 on %s" % colony.planet.planet_name)
								print("idle: %d" % idle_pop)	
									
						pass
					else:
						if industry >= 4:
							# TODO: pick party or science, if neither are available just wait
							keep_waiting = true
							pass
						else:
							keep_waiting = true
						pass
				else:
					# 0 prosperity
					if idle_pop > 0:
						project_candidate = "prosperity"
						pass
					else:
						# TODO: population can't grow and no idle people, need to demolish something
						print("prosperity 0 and no idlers on %s" % colony.planet.planet_name)
						pass
				pass
			else:
				# TODO: shift colony focus
				print("no buildable squares on %s" % colony.planet.planet_name)
				pass
		else:
			# TODO: shift colony focus
			#print("absolutely no free squares on %s" % colony.planet.planet_name)
			pass
		pass

	if project_candidate != null:
		var building = pick_building(project_candidate, colony.owner)
		if building == null:
			print(project_candidate)
		var square = pick_square(colony, project_candidate, building)
		var result = {
			"square": square,
			"type": "Surface",
			"project": building
		}
		return result
	else:
		#print("no project candidate on %s" % colony.planet.planet_name)
		pass

	
static func pick_square(colony, project, building):
	var result = null
	# TODO: account for projects that don't need a square
	var places = get_buildable_squares(colony)
	var prefs = BuildingDefinitions.tile_preference
	var target = null
	# if the picked project has a preference, find it
	if prefs.has(project):
		target = prefs[project]

	if target != null:
		# check all tiles for the preferred tile
		for coord in places:
			if places[coord].tiletype == target:
				result = coord
				break
		# if the tile is not available, pick any other (if possible)
		#if result == null:
			#print("couldn't find a tile while target needed for %s" % project)
	if target == null or result == null:
		# otherwise, pick an unspecific tile, preferring black(orfa) > white > green > blue > red
		var tile_priority = ["black", "white", "green", "blue", "red"]
		if colony.owner != null:
			if colony.owner.race.type != "orfa":
				tile_priority.remove(0)
			for prio in tile_priority:
				if result != null:
					break
				for coord in places:
					if places[coord].tiletype == prio:
						result = coord
						break
		if result == null:
			TurnHandler.auto(false)
			print("couldn't find a tile for %s on %s" % [project, colony.planet.planet_name])
			for p in places:
				if places[p].tiletype == null:
					print("found an empty tile at %s" % p)
				else: printt(places[p].tiletype, p)
			print("")
			print("target: %s" % target)
	return result

static func pick_building(project_candidate, player):
	var result = null
	var prefs = BuildingDefinitions.building_preference
	if prefs.has(project_candidate):
		for project in prefs[project_candidate]:
			if BuildingRules.project_available(player, project):
				result = project
				break
	else:
		result = project_candidate
	return result

static func get_buildable_squares(colony):
	# retrieves all squares that are neighbors to existing buildings
	var grid = colony.planet.grid
	var buildings = colony.planet.buildings
	var result = {}
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			if buildings[x][y].type == null and grid[x][y].tiletype != null and grid[x][y].buildable == true:
				result[Vector2(x, y)] = grid[x][y] # Maybe "true" would be enough, or an array of v2
	return result
			
static func get_replaceable_squares(colony):
	# buildings on normal squares can always be replaced
	# unless (normal rules) it would kill population
	# buildings on black squares have limited options
	# building area doesn't need to remain contiguous
	var grid = colony.planet.grid
	var buildings = colony.planet.buildings
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			pass

static func get_all_unused_squares(colony):
	var grid = colony.planet.grid
	var buildings = colony.planet.buildings
	var result = {}
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			if buildings[x][y].type == null and grid[x][y].tiletype != null:
				result[Vector2(x, y)] = grid[x][y]
	return result

static func decide_next_project(colony):
	var result = null
	
	pass

static func automate_something(colony):
	pass

static func start_colony_project(colony, project_key, type, position):
	var planet = colony.planet
	var player = planet.owner
	var grid = planet.grid
	var buildings = planet.buildings
	var orbitals = planet.orbitals

	if type == "Surface":
		var project = BuildingProject.new()
		var project_definition = BuildingDefinitions.building_defs[project_key]
		project.building = project_key

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
			# TODO: reset
		elif colony.project extends TechProject:
			# TODO: finish techproject cancel (should be simple)
			pass
		pass
	pass

static func start_surface_building(colony, new_project):
	colony.start_surface_building(new_project)

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
			# TODO: actually a techproject, but how will those know what tile they're working on? I don't want to make an orbital_automation..
			if project.building == "automation":
				pass
			building.active = true

			# special case for terraforming: reset the building
			if project.building == "terraforming":
				var cell = colony.planet.grid[x][y]
				cell.tiletype = "white"
				building.reset()

			# special case for xeno dig: reset the building tile and trigger a random research completion
			# research is triggered in turnhandler
			if project.building == "xeno_dig":
				building.reset()
			pass
		elif project extends OrbitalProject:
			var orbital = colony.planet.orbitals[x][y]
			pass
		elif project extends TechProject:
			pass
		else:
			print("Unknown project type")
	project = null
	colony.project = null
	pass

static func update_colony_stats(colony):
	colony.refresh()
	Planetmap.refresh_grids(colony.planet)
