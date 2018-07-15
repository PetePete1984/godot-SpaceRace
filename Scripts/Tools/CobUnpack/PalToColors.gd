static func get_palette(source):
	var colors = []

	var file = File.new()
	file.open(source, File.READ)
	var bytes = file.get_buffer(file.get_len())
	file.close()
	for i in range(bytes.size() / 3):
		var r = bytes[3 * i] * 4
		var g = bytes[3 * i + 1] * 4
		var b = bytes[3 * i + 2] * 4
		var col = Color8(r, g, b, 255)
		colors.append(col)
	return colors