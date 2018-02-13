extends TextureButton

var project
var tile
var type

signal project_picked(project, tile, type)

func _init(project, tile, type = "Surface", player = null):
	if type == "Surface":
		init_surface(project, tile)
	elif type == "Orbital":
		init_orbital(project, tile, player)
	elif type == "Tech":
		init_tech(project, tile)

	# TODO: make texturebutton and add to result list
	# FIXME: use real def
	set_tooltip(project.capitalize())
	# FIXME: formalize this into a variable, don't use the name
	set_name(project)
	self.project = project
	self.tile = tile
	self.type = type
	connect("pressed", self, "_emit_project")
	pass

func init_surface(project, tile):
	set_normal_texture(TextureHandler.get_surface_building(project))

func init_orbital(project, tile, player = null):
	set_normal_texture(TextureHandler.get_orbital_building(project, player))

func init_tech(project):
	set_normal_texture(TextureHandler.get_tech_project(project))

func _emit_project():
	#print("%s %s %s" % [project, str(tile), type])
	emit_signal("project_picked", project, tile, type)