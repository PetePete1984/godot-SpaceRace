extends "IndexedSettingsButton.gd"

func update_button(races):
	var races_index = range(mapdefs.min_races, mapdefs.max_races+1).find(races)
	var races_path = image_base_path + "/Races/%02d_%02d.png" % [races_index + 1, races]
	if files.file_exists(races_path):
		set_normal_texture(load(races_path))