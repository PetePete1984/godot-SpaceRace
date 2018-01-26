# Utils
extends Node

func rand_v3_in_unit_sphere(radius):
	# find a random position in 3D space
	var in_sphere = false
	var result = null
	while in_sphere == false:
		var x = rand_range(-radius, radius)
		var y = rand_range(-radius, radius)
		var z = rand_range(-radius, radius)
		if x*x + y*y + z*z <= radius*radius:
			in_sphere = true
			result = Vector3(x, y, z)
	return result
	
func rand_pick_from_dict(dict):
	var keys = dict.keys()
	var index = randi() % keys.size()
	return dict[keys[index]]
	
func rand_key_from_dict(dict):
	var keys = dict.keys()
	var index = randi() % keys.size()
	return keys[index]

func rand_pick_from_array(array):
	return array[randi() % array.size()]
	
func rand_pick_from_array_no_dupes(array, picked):
	var iterations = 0
	var index = randi() % array.size()
	while picked.has(array[index]) and iterations < 1000:
		index = randi() % array.size()
		iterations += 1
	if iterations >= 1000:
		print("Tried 1000 picks, always found duplicates. Maybe the list is too short.")
	return array[index]
	
func get_tile_neighbors(x, y, grid, diagonals = false):
	var neighbors = {
		"north": null,
		"south": null,
		"west": null,
		"east": null
	}
	
	if y-1 > 0:
		neighbors.north = grid[x][y-1]
	if y+1 < grid[0].size():
		neighbors.south = grid[x][y+1]
	if x-1 > 0:
		neighbors.west = grid[x-1][y]
	if x+1 < grid.size():
		neighbors.east = grid[x+1][y]
	
	if diagonals:
		neighbors.ne = null
		neighbors.nw = null
		neighbors.se = null
		neighbors.sw = null
		if y-1 > 0 and x+1 < grid.size():
			neighbors.ne = grid[x+1][y-1]
		if y+1 < grid[0].size() and x+1 < grid.size():
			neighbors.se = grid[x+1][y+1]
		if y-1 > 0 and x-1 > 0:
			neighbors.nw = grid[x-1][y-1]
		if x-1 > 0 and y+1 < grid[0].size():
			neighbors.sw = grid[x-1][y+1]
			
	return neighbors
	
func color255(r, g, b, a = 255):
	return Color(r/255.0, g/255.0, b/255.0, a/255.0)
	
func get_alpha_height(texture):
	if texture extends ImageTexture:
		var image = texture.get_data()
		var height = image.get_height()
		var width = image.get_width()
		var row_has_pixel = false
		var rows_with_pixels = []
		for y in range(height):
			row_has_pixel = false
			for x in range(width):
				var pixel = image.get_pixel(x, y)
				if pixel.a > 0:
					row_has_pixel = true
					break
			
			if row_has_pixel:
				rows_with_pixels.append(y)
		
		return rows_with_pixels.size()
	else:
		print("not an image texture, returning alpha = height")
		return texture.get_height()
	pass