extends SceneTree

const xform = preload("ImageTransformer.gd")

func _init():
	#rewrite_file("res://Scenes/TileSet_ShipModule.tscn", "res://Scenes/TileSet_ShipModule_fixed.tscn")
	#rewrite_file("res://tileset_shipmodules.tres", "res://tileset_shipmodules_fixed.tres")
	xform.to_grayscale_directory("res://Images/Races/Flags", "res://Images/Races/FlagsBW")
	quit()

func rewrite_file(source, destination):
	var file = File.new()
	if file.file_exists(source):
		var target = File.new()
		file.open(source, File.READ)
		target.open(destination, File.WRITE)

		var re = RegEx.new()
		re.compile("\\.shp_(\\d+)")

		while not file.eof_reached():
			var line = file.get_line()
			var match_pos = re.find(line)
			if match_pos > -1:
				var caps = re.get_captures()
				line = line.replace(caps[0], ".ascshp_%03d" % (int(caps[1]) - 1))
			target.store_line(line)
			

		file.close()
		target.close()
		pass