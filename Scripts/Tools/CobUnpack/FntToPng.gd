static func unfnt(source, palette):
	var height
	var transparent_color
	var images

	var destination = source.basename() + "_fnt"

	var dir = Directory.new()
	if not dir.dir_exists(destination):
		dir.make_dir_recursive(destination)

	var file = File.new()
	var status = file.open(source, File.READ)
	if status == OK:
		var verification_bytes = file.get_32()

		var character_count = file.get_32()
		height = file.get_32()
		transparent_color = file.get_32()
		var offsets = []

		for i in range(character_count):
			offsets.append(file.get_32())
		offsets.append(file.get_len())

		var width
		var color

		images = []

		for n in range(character_count):
			width = file.get_32()

			if width == 0:
				continue

			var image = Image(width, height, false, Image.FORMAT_RGBA)
			for y in range(height):
				for x in range(width):
					var color = file.get_8()
					if color == transparent_color:
						image.put_pixel(x, y, Color(0,0,0,0))
					else:
						image.put_pixel(x, y, palette[color])
			
			var path_image = destination.plus_file("%05d.png" % n)
			#print(path_image)
			image.save_png(path_image)
	file.close()
	