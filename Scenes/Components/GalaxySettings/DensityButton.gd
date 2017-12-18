extends "IndexedSettingsButton.gd"

func _ready():
	pass

func update_button(density):
	var density_index = mapdefs.galaxy_sizes.find(density)
	var density_path = image_base_path + "/Density/%02d_%s.png" % [density_index + 1, density]
	if files.file_exists(density_path):
		set_normal_texture(load(density_path))