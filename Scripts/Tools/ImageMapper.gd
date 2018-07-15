const cob_path = "res://Cob"
const image_path = "res://ImagesX"
const mapping_path = "res://Data/ImageMappings.csv"

const csv2dict = preload("res://Scripts/Tools/CSVtoDict.gd")

static func load_mappings():
	var mappings = csv2dict.get_data_array_from_CSV(mapping_path)
	return mappings

static func map_all():
	var mappings = [
		{
			"map_from": "cob1/data/10status/10status.tmp_000.png",
			"map_to": "Screens/PlanetList/border.png"
		}
	]
	
	# mappings can also be used to find missing files for setup completion's sake
	mappings = load_mappings()

	for mapping in mappings:
		if mapping.map_to != "":
			var dir = Directory.new()
			var path_from = cob_path.plus_file(mapping.map_from)
			var path_to = image_path.plus_file(mapping.map_to)

			var folder_to = path_to.get_base_dir()
			if not dir.dir_exists(folder_to):
				dir.make_dir_recursive(folder_to)

			if dir.file_exists(path_from):
				dir.copy(path_from, path_to)
				printt("copied", path_from, path_to)
