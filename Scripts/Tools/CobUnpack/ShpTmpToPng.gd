class PicInShp:
	var index
	var filename
	var offset
	var palette_offset

	var height
	var width
	var y_center
	var x_center
	var y_start
	var x_start
	var y_end
	var x_end

static func get_u8(stream, file):
	stream.set_data_array(file.get_buffer(1))
	return stream.get_u8()

static func get_u16(stream, file):
	stream.set_data_array(file.get_buffer(2))
	return stream.get_u16()

static func unshape(source, palette):
	var pics = []
	var file = File.new()
	file.open(source, File.READ)
	var magic_bytes = file.get_32()
	var num_images = file.get_32()
	var destination = source.basename()
	var background = Color(0, 0, 0, 0)

	var dir = Directory.new()
	if not dir.dir_exists(destination):
		dir.make_dir_recursive(destination)
	
	for index in range(0, num_images):
		var pic = PicInShp.new()
		pic.index = index
		# TODO: the other python script used rjust, no reason to, will just need to adjust code elsewhere
		pic.filename = destination.plus_file("%s_%03d.png" % [source.get_file(), index])
		pic.offset = file.get_32()
		pic.palette_offset = file.get_32()
		pics.append(pic)

	for pic in pics:
		var imageStream = StreamPeerBuffer.new()
		var colors = []
		file.seek(pic.offset)

		pic.height = get_u16(imageStream, file) + 1
		pic.width = get_u16(imageStream, file) + 1

		pic.y_center = get_u16(imageStream, file)
		pic.x_center = get_u16(imageStream, file)

		pic.x_start = file.get_32() + pic.x_center
		pic.y_start = file.get_32() + pic.y_center

		pic.x_end = file.get_32() + pic.x_center
		pic.y_end = file.get_32() + pic.y_center

		if pic.x_start < -pic.x_center:
			pic.x_start = 0

		if pic.x_end > pic.width:
			pic.x_end = pic.width - 1 - pic.x_center

		if pic.y_start < -pic.y_center:
			pic.y_start = 0

		if pic.y_end > pic.height:
			pic.y_end = pic.height - 1 - pic.y_center
			pass
		
		var image = Image(pic.width, pic.height, false, Image.FORMAT_RGBA)
		for y in range(pic.height):
			for x in range(pic.width):
				image.put_pixel(x, y, background)
				if not colors.has(background):
					colors.append(background)

		var x = pic.x_start
		var y = pic.y_start

		var next_byte
		var color_index
		var pixels_to_fill

		while y <= pic.y_end:
			next_byte = get_u8(imageStream, file)
			if next_byte == 0:
				while x <= pic.x_end:
					image.put_pixel(x, y, background)
					if not colors.has(background):
						colors.append(background)
					x += 1
				x = pic.x_start
				y += 1
			elif next_byte == 1:
				pixels_to_fill = get_u8(imageStream, file)
				for pix in range(pixels_to_fill):
					image.put_pixel(x, y, background)
					if not colors.has(background):
						colors.append(background)
					x += 1
			elif next_byte & 1 == 0:
				color_index = get_u8(imageStream, file)
				pixels_to_fill = next_byte >> 1
				for pix in range(pixels_to_fill):
					image.put_pixel(x, y, palette[color_index])
					if not colors.has(palette[color_index]):
						colors.append(palette[color_index])
					x += 1
			elif next_byte & 1 == 1:
				pixels_to_fill = next_byte >> 1
				for pix in range(pixels_to_fill):
					color_index = get_u8(imageStream, file)
					image.put_pixel(x, y, palette[color_index])
					if not colors.has(palette[color_index]):
						colors.append(palette[color_index])
					x += 1

		if colors.size() == 1:
			if colors[0] == Color(0,0,0,1):
				for y in range(pic.height):
					for x in range(pic.width):
						image.put_pixel(x, y, background)

		image.save_png(pic.filename)

	file.close()
	pass
