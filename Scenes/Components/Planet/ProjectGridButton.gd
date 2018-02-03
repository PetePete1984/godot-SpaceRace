extends TextureButton

var project
var tile
var type

signal project_picked(project, tile, type)

const image_base_path = "res://Images/Screens/Planet/Buildings"

func _init(project, tile, type = "Surface"):
	if type == "Surface":
		init_surface(project, tile)
	elif type == "Orbital":
		init_orbital(project, tile)

	# TODO: make texturebutton and add to result list
	set_tooltip(project.capitalize())
	# FIXME: formalize this into a variable, don't use the name
	set_name(project)
	self.project = project
	self.tile = tile
	self.type = type
	connect("pressed", self, "_emit_project")
	self.type = type
	pass

func load_texture(index, type, project):
	var path = "%s/%s/%02d_%s.png" % [image_base_path, type, index+1, project]
	if File.new().file_exists(path):
		return load(path)
	else:
		print("File not found: %s" % path)

func init_surface(project, tile):
	var index = BuildingDefinitions.building_types.find(project)
	set_normal_texture(load_texture(index, "Surface", project))

func init_orbital(project, tile):
	var index = OrbitalDefinitions.orbital_types.find(project)
	set_normal_texture(load_texture(index, "Orbital", project))

func init_tech(project):
	pass

func _emit_project():
	#print("%s %s %s" % [project, str(tile), type])
	emit_signal("project_picked", project, tile, type)