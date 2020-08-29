var astar_instance
var grid_ids
var ids_grids
var planet

func _init():
	astar_instance = AStar.new()

func init_astar_grid(for_planet):
	planet = for_planet
	var grid = planet.grid
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			var tile = grid[x][y]
			if tile != null:
				if tile.tiletype != null:
					var weight = mapdefs.cell_weights[mapdefs.cell_types.find(tile.tiletype)]
					
					# add weighted astar point

	# iterate over the grid again, connecting neighbors
	pass

func find_path_to_tile(start, end):
	pass

# realistically, building will always be xeno, but eh
func find_path_to_building(start, building):
	var grid = planet.buildings
	var target = null

	# find building
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			var building_tile = grid[x][y]
			if building_tile != null:
				if building_tile.type != null:
					if building_tile.type.type == building:
						target = [x, y]
	
	if target != null:
		# find path
		pass
	pass

func find_path_to_tile_type(start, type):
	pass