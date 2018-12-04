# Galaxy Generator
extends Reference

const Galaxy = preload("res://Scripts/Model/Galaxy.gd")
const StarLane = preload("res://Scripts/Model/StarLane.gd")
const StarSystemGenerator = preload("res://Scripts/Generator/StarSystemGenerator.gd")

const LANE_DISTANCE_FACTOR = 250

enum CONNECT_METHOD { PRIM, KRUSKAL, CLUSTER }

class SystemSorter:
	static func sort_by_distance(a, b):
		return a.distance < b.distance

	static func sort_by_position(a, b):
		return a.position > b.position

static func random_size():
	return Utils.rand_pick_from_array(mapdefs.galaxy_sizes)
	pass

# TODO: Split into init, stars and star system phases
static func generate_galaxy(size):
	var galaxy = generate_stars(size)
	generate_star_systems(galaxy)
	return galaxy

# only generate stars
static func generate_stars(size):
	if size == null or size == "":
		size = random_size()
		
	var galaxy = Galaxy.new()
	var used_star_names = []
	var used_positions = []

	for s in range(mapdefs.galaxy_size[size]):
		# generate star without planets
		# TODO: Give star systems an index
		var sys = StarSystemGenerator.generate_star(used_star_names, s)
		# generate system position
		var radius = 1
		var integer_pos = false
		var sys_pos = Utils.rand_v3_in_unit_sphere(radius, integer_pos)
		
		var iterations = 0
		while used_positions.has(sys_pos):
			sys_pos = Utils.rand_v3_in_unit_sphere(radius, integer_pos)
			iterations += 1
			if iterations >= 10000:
				print("Stuck generating star systems, ran out of unique positions after 10000")
				break
		
		used_positions.append(sys_pos)
		sys.position = sys_pos
		# store system
		#galaxy.systems[sys_pos] = sys
		galaxy.systems.append(sys)
		pass
	return galaxy

# only generate systems when stars are done
static func generate_star_systems(galaxy):
	for system in galaxy.systems:
		#var system = galaxy.systems[sys]
		StarSystemGenerator.generate_planets(system)
	pass
	
static func connect_star_systems(galaxy):
	# TODO: simple connections first. find highest planet on y and then connect to the closest until all have been walked
	# TODO: walk through the systems and spawn connections
	# TODO: maybe connect second closest too
	# TODO: otherwise delaunay, gabriel, urquhart, relative neighborhood
	# https://en.wikipedia.org/wiki/Urquhart_graph
	# https://en.wikipedia.org/wiki/Delaunay_triangulation
	# https://en.wikipedia.org/wiki/Gabriel_graph
	# https://en.wikipedia.org/wiki/Nearest_neighbor_graph
	# https://en.wikipedia.org/wiki/Relative_neighborhood_graph
	# https://en.wikipedia.org/wiki/Prim%27s_algorithm
	# https://en.wikipedia.org/wiki/Kruskal%27s_algorithm
	# https://en.wikipedia.org/wiki/Disjoint-set_data_structure

	# Using Prim's Algorithm for now because the others make me feel stupid
	connect_prim(galaxy)
	return

# plunk races into random systems
static func distribute_races(galaxy):
	pass

static func connect_prim(galaxy):
	var graph = []

	var unreached = []
	unreached.resize(galaxy.systems.size())
	# just pick the first that's in there
	var reached = [galaxy.systems.front()]

	for i in range(galaxy.systems.size()):
		unreached[i] = galaxy.systems[i]

	unreached.erase(galaxy.systems.front())

	while unreached.size() > 0:
		var distance = 10000;
		var closest
		var edges = []
		for from in reached:
			for to in unreached:
				var key = [from, to]
				var key_invert = [to, from]
				# if !(edges.has(key) and edges.has(key_invert)):
				# FIXME: use distance_squared_to or length_squared
				var dist = (to.position - from.position).length()
				if dist < distance:
					closest = {
						"from": from,
						"to": to,
						"distance": dist
					}
					distance = dist
					# neighbors.append({
					# 	"from": from,
					# 	"to": to,
					# 	"distance": distance
					# })
					# edges.append(key)

		#neighbors.sort_custom(SystemSorter, "sort_by_distance")

		#var closest = neighbors[0]
		unreached.erase(closest.to)
		reached.append(closest.to)
		graph.append(closest)

	for edge in graph:
		make_starlane(galaxy, edge.from, edge.to)

static func make_starlane(galaxy, from, to):
	var lane = StarLane.new()
	lane.connects = [from, to]
	lane.galactic_positions = [from.position, to.position]
	if not lane.connects in galaxy.lanes:
		galaxy.lanes[lane.connects] = lane
	var from_to = (to.position - from.position).normalized() * 5
	var to_from = (from.position - to.position).normalized() * 5
	var matching = from_to == -to_from
	#print(matching)
	lane.directions = [from_to, to_from]
	lane.positions = [from_to, to_from]
	lane.length = int((to.position - from.position).length() * LANE_DISTANCE_FACTOR)
	#print(lane.length)
	from.lanes[from_to] = lane
	to.lanes[to_from] = lane


# region unused
static func connect_attempt1(galaxy):

	# var graph = []
	# var connected = []
	# var edges = {}

	# for from in galaxy.systems:
	# 	for to in galaxy.systems:
	# 		if from != to:
	# 			var key = [from, to]
	# 			var key_flipped = [to, from]
	# 			if !(edges.has(key) or edges.has(key_flipped)):
	# 				var distance = (from.position - to.position).length()
	# 				edges[key] = distance
	# 			pass
	# 		pass

	# var sorted_edges = []
	# for edge_key in edges.keys():
	# 	var distance = edges[edge_key]
	# 	sorted_edges.append({
	# 		"from": edge_key[0],
	# 		"to": edge_key[1],
	# 		"distance": distance
	# 	})

	# sorted_edges.sort_custom(SystemSorter, "sort_by_distance")

	# for edge in sorted_edges:
	# 	if edge.from in connected or edge.to in connected:
	# 		continue
	# 	if not edge.from in connected:
	# 		connected.append(edge.from)
	# 	if not edge.to in connected:
	# 		connected.append(edge.to)
	# 	graph.append(edge)

	# print(graph.size())

	# for edge in graph:
	# 	make_starlane(galaxy, edge.from, edge.to)
	# return
	pass

static func connect_attempt2(galaxy):
	var sortable_systems = []
	sortable_systems.resize(galaxy.systems.size())
	for index in range(galaxy.systems.size()):
		sortable_systems[index] = galaxy.systems[index]

	sortable_systems.sort_custom(SystemSorter, "sort_by_position")
	print(sortable_systems[0].position)

	var connected = []
	var edges = []
	var i = 0
	var current_system = Utils.rand_pick_from_array(sortable_systems)
	connected.append(current_system)

	while i < sortable_systems.size() -1:
		var neighbors = []
		for other_system in galaxy.systems:
			if other_system == current_system:
				continue
			else:
				var distance = (current_system.position - other_system.position).length()
				neighbors.append({
					"from": current_system,
					"to": other_system,
					"distance": distance
				})
		neighbors.sort_custom(SystemSorter, "sort_by_distance")
		for neighbor in neighbors:
			if neighbor.to in connected:
				continue
			else:
				edges.append(neighbor)
				connected.append(neighbor.to)
				current_system = neighbor.to
				i += 1

		
	print(edges.size())
	for edge in edges:
		make_starlane(galaxy, edge.from, edge.to)

static func connect_attempt3(galaxy):
	var connected = []
	var sortable_systems = []
	for system in sortable_systems:
		var system_position = system.position
		var neighbors = []
		if not system in connected:
			connected.append(system)
		else:
			continue
		for other_system in galaxy.systems:
			if other_system != system and not other_system in connected:
				var other_position = other_system.position
				var distance = (other_position - system_position).length()
				neighbors.append({
					"distance": distance,
					"to": other_system
				})

		neighbors.sort_custom(SystemSorter, "sort_by_distance")

		for index in range(min(neighbors.size(), 1)):
			make_starlane(galaxy, system, neighbors[index].to)
			if not neighbors[index].to in connected:
				connected.append(neighbors[index].to)

static func connect_attempt4(galaxy):
		# for system in galaxy.systems:
	# 	var system_position = system.position
	# 	# find the closest unconnected system
	# 	# var minimum = 100
	# 	# var closest_pos = null
	# 	# var closest_sys = null

	# 	var neighbors = []
		

	# 	#neighbors.resize(galaxy.systems.size())

	# 	for other_system in galaxy.systems:
	# 		var other_position = other_system.position
	# 		if other_system != system:
	# 			var distance = (other_position - system_position).length()
	# 			neighbors.append({
	# 				"distance": distance,
	# 				"to": other_system
	# 			})

	# 	# sort by distance
	# 	neighbors.sort_custom(SystemSorter, "sort_by_distance")
	# 	#print(var2str(neighbors))
		
	# 	for index in range(2):
	# 		make_starlane(galaxy, system, neighbors[index].to)

		# for other_system in galaxy.systems:
		# 	var other_position = other_system.position
		# 	if system_position != other_position:
		# 		var distance = (other_position - system_position).length()
		# 		if distance < minimum:
		# 			closest_pos = other_position
		# 			closest_sys = other_system
		# 			minimum = distance


		# conjure up a star lane
		# if closest_pos != null and closest_sys != null:
		# 	var lane = StarLane.new()
		# 	lane.connects = [system, closest_sys]
		# 	lane.galactic_positions = [system_position, closest_pos]
		# 	if not lane.connects in galaxy.lanes:
		# 		galaxy.lanes[lane.connects] = lane
		# 	var from_to = (closest_pos - system_position).normalized() * 5
		# 	var to_from = (system_position - closest_pos).normalized() * 5
		# 	lane.directions = [from_to, to_from]
		# 	lane.positions = [from_to, to_from]
		# 	if first:
		# 		#print(from_to)
		# 		#print(to_from)
		# 		first = false
		# 	system.lanes[from_to] = lane
		# 	closest_sys.lanes[to_from] = lane