extends Node

var astar_points
var system_ids = {}
var ids_systems = {}

# TODO: try putting a virtual point inbetween systems to hold the lane weight

func get_astar_from_galaxy(galaxy):
	astar_points = AStar.new()
	for system in galaxy.systems:
		var system_position = system.position
		var next_free_id = astar_points.get_available_point_id()
		astar_points.add_point(next_free_id, system_position)
		system_ids[next_free_id] = system
		ids_systems[system] = next_free_id

	for lane_key in galaxy.lanes:
		var lane = galaxy.lanes[lane_key]
		var from = lane.connects[0]
		var to = lane.connects[1]
		var from_id = ids_systems[from]
		var to_id = ids_systems[to]
		astar_points.connect_points(from_id, to_id)

func get_route(from, to):
	var from_id = ids_systems[from]
	var to_id = ids_systems[to]
	var id_route = astar_points.get_id_path(from_id, to_id)
	var route = []
	for id in id_route:
		route.append(system_ids[id].system_name)
	return route