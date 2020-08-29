# Utils
extends Node

static func randf_between(min_num, max_num):
	var num = randf()
	return num

static func randi_between(min_num, max_num):
	var nums = range(min_num, max_num)
	var num = nums[randi() % nums.size()]
	return num

static func rand_between(lowest, highest):
	return rand_range(lowest, highest)

func rand_v2_in_unit_circle(radius, integers = false):
	var rand_func
	if integers:
		rand_func = funcref(self, "randi_between")
	else:
		rand_func = funcref(self, "rand_between")
	var in_circle = false
	var result = null
	while in_circle == false:
		var x = rand_func.call_func(-radius, radius)
		var y = rand_func.call_func(-radius, radius)
		var pos = Vector2(x, y)
		if pos.length_squared() <= radius*radius:
			in_circle = true
			result = pos
	return result


func rand_v3_in_unit_sphere(radius, integers = false):
	# find a random position in 3D space
	var rand_func
	if integers:
		rand_func = funcref(self, "randi_between")
	else:
		rand_func = funcref(self, "rand_between")
	var in_sphere = false
	var result = null
	while in_sphere == false:
		#var x = rand_range(-radius, radius)
		#var y = rand_range(-radius, radius)
		#var z = rand_range(-radius, radius)
		var x = rand_func.call_func(-radius, radius)
		var y = rand_func.call_func(-radius, radius)
		var z = rand_func.call_func(-radius, radius)
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
	var copy = []
	for i in array:
		if not i in picked:
			copy.append(i)

	if copy.size() > 0:
		return rand_pick_from_array(copy)
	else:
		print("Array list picks exhausted, need a bigger list")

func array_shuffle(array):
	for i in range(array.size()):
		var swap_val = array[i]
		var swap_index = int(rand_range(i, array.size()))

		array[i] = array[swap_index]
		array[swap_index] = swap_val

func array_intersect(small_set, big_set):
	var result = true
	for s in small_set:
		result = result and s in big_set
		if result == false:
			break
	return result
	
func get_tile_neighbors(x, y, grid, diagonals = false):
	var neighbors = {
		"north": null,
		"south": null,
		"west": null,
		"east": null
	}
	
	if y-1 >= 0:
		neighbors.north = grid[x][y-1]
	if y+1 < grid[0].size():
		neighbors.south = grid[x][y+1]
	if x-1 >= 0:
		neighbors.west = grid[x-1][y]
	if x+1 < grid.size():
		neighbors.east = grid[x+1][y]
	
	if diagonals:
		neighbors.ne = null
		neighbors.nw = null
		neighbors.se = null
		neighbors.sw = null
		if y-1 >= 0 and x+1 < grid.size():
			neighbors.ne = grid[x+1][y-1]
		if y+1 < grid[0].size() and x+1 < grid.size():
			neighbors.se = grid[x+1][y+1]
		if y-1 >= 0 and x-1 >= 0:
			neighbors.nw = grid[x-1][y-1]
		if x-1 >= 0 and y+1 < grid[0].size():
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