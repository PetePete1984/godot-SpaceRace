extends "IndexedSettingsButton.gd"

func update_button(atmosphere):
	var atmosphere_index = mapdefs.atmospheres.find(atmosphere)
	var atmosphere_path = image_base_path + "/Atmosphere/%02d_%s.png" % [atmosphere_index + 1, atmosphere]
	if files.file_exists(atmosphere_path):
		set_normal_texture(load(atmosphere_path))