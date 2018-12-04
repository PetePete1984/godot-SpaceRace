static func write_dict_to_json_file(dict, destination):
	var json_data = dict.to_json()
	
	var dir = Directory.new()
	var folder_target = destination.basename()
	
	if not dir.dir_exists(folder_target):
		dir.make_dir_recursive(folder_target)
		
	var file = File.new()
	var status = file.open(destination, File.WRITE)

	if status == OK:
		file.store_line(json_data)
	file.close()