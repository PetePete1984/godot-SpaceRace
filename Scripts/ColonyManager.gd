# Colony Manager

# imports for type checking
const BuildingProject = preload("res://Scripts/Model/BuildingProject.gd")
const TechProject = preload("res://Scripts/Model/TechProject.gd")
const OrbitalProject = preload("res://Scripts/Model/OrbitalProject.gd")

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
		
		var terraforming_available
		var growth_bomb_available
		var automation_available
		var hyperpower_available
		var hyperpower_exists
		var internet_available
		var internet_exists
		
		if num_all_squares > 0:
			if num_buildable_squares > 0:
				if prosperity > 0:
					if idle_pop > 0:
						if all_reachable_are_black:
							# FIXME: extract as "handle_black_square"
							if colony.owner.race == "orfa":
								pick_a_white_square(colony)
							else:
								if terraforming_available:
									project_candidate = "terraform"
								else:
									if all_unused_are_black:
										# wait for terraforming
										keep_waiting = true
									else:
										# TODO: pathfind to better squares?
										project_candidate = "tubes"
						else:
							# non-black squares available
							if free_pop > 0:
								if free_pop < 2 and num_all_squares > free_pop:
									if growth_bomb_available:
										if colony.planet.growth_bombed == true:
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
										project_candidate = "pure_prosperity"
									elif free_red_square:
										if global_research < 5 and free_blue_square:
											project_candidate = "pure_research"
										else:
											project_candidate = "pure_industry"
									elif free_blue_square:
										project_candidate = "pure_research"
									elif free_green_square:
										project_candidate = "pure_prosperity"
									elif free_white_square:
										# FIXME: apply some kind of global tech level
										# TODO: can this look more readable?
										if global_research >= 5:
											if industry >= 10:
												if hyperpower_available:
													if hyperpower_exists:
														if industry >= 25:
															if research >= 12:
																if internet_available:
																	if internet_exists:
																		project_candidate = "pure_research"
																	else:
																		project_candidate = "internet"
																else:
																	project_candidate = "pure_research"
															else:
																project_candidate = "pure_research"
														else:
															project_candidate = "pure_industry"
													else:
														project_candidate = "hyperpower"
												else:
													project_candidate = "pure_industry"
											else:
												project_candidate = "pure_industry"
										else:
											project_candidate = "pure_research"
										pass
									elif free_black_square:
										# FIXME: extract as "handle_black_square"
										if colony.owner.race == "orfa":
											pick_a_white_square(colony)
										else:
											if terraforming_available:
												project_candidate = "terraform"
											else:
												if all_unused_are_black:
													# wait for terraforming
													keep_waiting = true
												else:
													# TODO: pathfind to better squares?
													project_candidate = "tubes"
									pass
									
									
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
						project_candidate = "pure_prosperity"
						pass
					else:
						# TODO: population can't grow and no idle people, need to demolish something
						pass
				pass
			else:
				# TODO: shift colony focus
				pass
		else:
			# TODO: shift colony focus
			pass
		pass
	
	return project_candidate
	pass
	
static func get_buildable_squares(colony):
	# retrieves all squares that are neighbors to existing buildings
	var grid = colony.planet.grid
	var buildings = colony.planet.buildings
	var result = {}
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			if buildings[x][y].type == null and grid[x][y].buildable == true:
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
			if buildings[x][y].type == null:
				result[Vector2(x, y)] = grid[x][y]
	return result

static func decide_next_project(colony):
	var result = null
	
	pass