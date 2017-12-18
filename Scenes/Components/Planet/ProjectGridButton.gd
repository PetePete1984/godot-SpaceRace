extends TextureButton

var project
var tile
var type

signal project_picked(project, tile, type)

const image_base_path = "res://Images/Screens/Planet/Buildings"

func _init(project, tile, type = "Surface"):
	# FIXME: rename files to remove capitalize
	var building_index = BuildingDefinitions.building_types.find(project)
	var path = "%s/%s/%02d_%s.png" % [image_base_path, type, building_index+1, project]
	if File.new().file_exists(path):
		var texture = load(path)
		# TODO: make texturebutton and add to result list
		set_normal_texture(texture)
		set_tooltip(project.capitalize())
		# FIXME: formalize this into a variable, don't use the name
		set_name(project)
		self.project = project
		self.tile = tile
		self.type = type
		connect("pressed", self, "_emit_project")
	else:
		print("File not found: %s" % path)
	pass

func _emit_project():
	print("%s %s %s" % [project, str(tile), type])
	emit_signal("project_picked", project, tile, type)