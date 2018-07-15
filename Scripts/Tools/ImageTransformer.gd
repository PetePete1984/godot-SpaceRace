static func to_grayscale_directory(source, destination):
	var dir = Directory.new()
	if not dir.dir_exists(source):
		print("Source directory missing")
	else:
		if not dir.dir_exists(destination):
			dir.make_dir_recursive(destination)

		if dir.open(source) == OK:
			dir.list_dir_begin()
			var file_name = dir.get_next()
			while file_name != "":
				if not dir.current_is_dir():
					if file_name.extension() == "png":
						to_grayscale(dir.get_current_dir().plus_file(file_name), destination.plus_file(file_name))
				file_name = dir.get_next()

static func to_grayscale(source, destination, method = 1):
	var original = load(source)
	var tex = original.get_data()
	var gs_copy = Image(tex.get_width(), tex.get_height(), false, Image.FORMAT_RGBA)
	var gray_vec = Vector3(0.299, 0.587, 0.114)
	var shift = Vector3(1.8, 1.3, 1) * 1.33
	var shift_add = shift.x + shift.y + shift.z
	var shift_brightness_vec = Vector3(shift_add, shift_add, shift_add) / 3.0
	var luminance = Vector3(1, 1.5, 0.5)
	var asc_blues = [Color8(12, 32, 48, 255), Color8(12, 36, 48, 255)]

	for y in range(tex.get_height()):
		for x in range(tex.get_width()):
			var color_org = tex.get_pixel(x, y)
			if method == 1:
				var component = color_org.gray()
				var color_gray = Color(component, component, component, color_org.a)
				if not color_org in asc_blues:
					color_gray.v = color_gray.v * 3
				else:
					color_gray.v = 0
				
				gs_copy.put_pixel(x, y, color_gray)
			elif method == 2:
				var color_vec = Vector3(color_org.r, color_org.g, color_org.b)
				var color_gray_float = color_vec.dot(gray_vec)
				var color_gray_vec = Vector3(color_gray_float, color_gray_float, color_gray_float)
	
				var component = color_gray_vec * shift_brightness_vec
	
				var color_mix = Color(component.x, component.y, component.z, color_org.a)
	
				gs_copy.put_pixel(x, y, color_mix)
			elif method == 3:
				pass

			

	gs_copy.save_png(destination)
	#var target = File.new()
	#target.open(destination, File.WRITE)
	#target.close()
	pass