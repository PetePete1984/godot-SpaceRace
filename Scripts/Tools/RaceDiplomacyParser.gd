extends Reference

const path = "res://Data/Diplomacy/%s.dip"

static func read_diplomacy(token):
	var contents = []
	var diplomacy_values = {
		"thresholds": {},
		"actions": {},
		"responses": {}
	}

	var buffer = []
	var buffering = false
	var dipvalues_start = -1
	var dipvalues_end = -1

	# regexr: /(\w*?)\s+(-?\w+)\n?/gim
	var dipvalue_regex = RegEx.new()
	dipvalue_regex.compile("(\\w*?)\\s+(-?\\w+)")

	var file = File.new()
	if file.file_exists(path % token):
		file.open(path % token, File.READ)
		while not file.eof_reached():
			contents.append(file.get_line())
		file.close()

		var line_index = 0
		for line in contents:
			if line.begins_with("DIPVALUES"):
				# TODO: extract diplomacy thresholds
				dipvalues_start = line_index + 1
			elif line.begins_with("ACTIONS"):
				dipvalues_end = line_index - 1
			elif line.begins_with("DA_"):
				# TODO: extract diplomacy actions
				var key = line.strip_edges()
				var value = contents[line_index + 1]
				diplomacy_values.actions[key] = value
			elif line.begins_with("DR_"):
				# TODO: extract diplomacy responses
				var key = line.strip_edges()
				var value = contents[line_index + 1]
				diplomacy_values.responses[key] = value
			line_index += 1

		for index in range(dipvalues_start, dipvalues_end):
			var line = contents[index]
			if not line.empty():
				var regex_result = dipvalue_regex.find(line)
				if regex_result != -1:
					#for reg_index in range(dipvalue_regex.get_capture_count()):
					var matches = dipvalue_regex.get_captures()
					diplomacy_values.thresholds[matches[1].to_lower()] = matches[2].to_int()

				# print("\"" + line + "\"")
		
		return diplomacy_values
	else:
		print("File not found: Data/Diplomacy/%s.dip" % token)
	pass