static func get_dict_from_CSV(source):
	var file = File.new()
	var result = {}
	if file.file_exists(source):
		file.open(source, File.READ)
		var first_line = true
		var temp_dict = {}
		var headers = []
		while not file.eof_reached():
			var line = file.get_csv_line()

			if first_line:
				headers = line
				first_line = false
			else:
				for i in range(headers.size()):
					var header = headers[i]
					temp_dict[header] = line[i]
		
		result = temp_dict
	file.close()
	return result

static func get_keyed_dict_from_CSV(source, key):
	var file = File.new()
	var result = {}
	if file.file_exists(source):
		file.open(source, File.READ)

		var first_line = true
		var headers = []

		while not file.eof_reached():
			var line = file.get_csv_line()
			var line_dict = {}

			if first_line:
				headers = line
				first_line = false
			else:
				var line_dict = {}
				for i in range(headers.size()):
					var header = headers[i]
					var value = line[i]
					if value.is_valid_integer():
						value = value.to_int()
					elif value.to_upper() == "TRUE":
						value = true
					elif value.to_upper() == "FALSE":
						value = false
					line_dict[header] = value

				var object_key = line_dict[key]
				result[object_key] = line_dict

		file.close()
		return result

static func get_data_array_from_CSV(source):
	var file = File.new()
	var result = []
	if file.file_exists(source):
		file.open(source, File.READ)
		var first_line = true
		var headers = []
		var line_dict = {}
		while not file.eof_reached():
			var line = file.get_csv_line()
			line_dict = {}

			if first_line:
				headers = line
				first_line = false
			else:
				for i in range(headers.size()):
					var header = headers[i]
					line_dict[header] = line[i]
				result.append(line_dict)
		file.close()
		return result
	else:
		file.close()
		print("file not found: ", source)
		return []