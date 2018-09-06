class FileInCob:
	var original_path
	var filepath
	var filename
	var filesize
	var fileoffset

static func unpack(cob, source, destination):
	var file = File.new()
	var dir = Directory.new()
	prints("attempting to open", source)
	var status = file.open(source, File.READ)
	prints("result", status, OK)
	var num_files = file.get_32()
	var files = []

	for i in range(0, num_files):
		var path = file.get_buffer(50).get_string_from_utf8()
		# replace filename extensions that godot would otherwise attempt to import
		path = path.replace(".shp", ".ascshp")
		path = path.replace(".fnt", ".ascfnt")
		
		var file_in_cob = FileInCob.new()
		file_in_cob.original_path = path
		var tokens = path.split(OLD_SEPARATOR)
		
		if tokens.size() > 1:
			file_in_cob.filepath = tokens[0]
			file_in_cob.filename = tokens[1]
		else:
			file_in_cob.filepath = ""
			file_in_cob.filename = path
		files.append(file_in_cob)

	for i in range(0, num_files):
		var file_offset = file.get_32()
		files[i].fileoffset = file_offset
		if i > 0:
			files[i-1].filesize = files[i].fileoffset - files[i-1].fileoffset

	file.seek_end()
	files[num_files-1].filesize = file.get_pos() - files[num_files-1].fileoffset

	if not dir.dir_exists(destination):
		dir.make_dir(destination)

	for f in files:
		#printt(f.filepath, f.filename, f.filesize)
		var final_dir = destination.plus_file(f.filepath)
		if not dir.dir_exists(final_dir):
			dir.make_dir_recursive(final_dir)
			
		var final_path = destination.plus_file(f.filepath).plus_file(f.filename)

		var write_file = File.new()
		write_file.open(final_path, File.WRITE)
		file.seek(f.fileoffset)
		write_file.store_buffer(file.get_buffer(f.filesize))
		write_file.close()
		pass

	file.close()
	pass

const OLD_SEPARATOR = "\\"