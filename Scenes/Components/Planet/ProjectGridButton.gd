extends TextureButton

var project
var tile
var type

signal project_picked(project, tile, type)

func _init(init_project, init_tile, init_type = "Surface", player = null):
	var tooltip = ""
	if init_type == "Surface":
		init_surface(init_project, init_tile)
		tooltip = BuildingDefinitions.get_name(init_project)
		#tooltip = BuildingDefinitions.building_defs[init_project].building_name
	elif init_type == "Orbital":
		if init_project == "ship_placeholder":
			set_normal_texture(TextureHandler.get_ship(player))
			tooltip = "Ship"
		else:
			init_orbital(init_project, init_tile, player)
			tooltip = OrbitalDefinitions.get_name(init_project)
			#tooltip = OrbitalDefinitions.orbital_defs[init_project].orbital_name
	elif init_type == "Tech":
		init_tech(init_project, init_tile)
		tooltip = TechProjectDefinitions.get_name(init_project)
		#tooltip = TechProjectDefinitions.project_defs[init_project].project_name

	# TODO: make texturebutton and add to result list
	set_tooltip(tooltip)
	# FIXME: formalize this into a variable, don't use the name
	set_name(init_project)
	project = init_project
	tile = init_tile
	type = init_type
	connect("pressed", self, "_emit_project")
	pass

func _ready():
	set("stretch_mode", 6)
	set("size_flags/horizontal", 1)
	set("size_flags/vertical", 1)
	set("rect/min_size", Vector2(68, 52))

func init_surface(project, tile):
	set_normal_texture(TextureHandler.get_surface_building(project))

func init_orbital(project, tile, player = null):
	set_normal_texture(TextureHandler.get_orbital_building(project, player))

func init_tech(project):
	set_normal_texture(TextureHandler.get_tech_project(project))

func _emit_project():
	#print("%s %s %s" % [project, str(tile), type])
	emit_signal("project_picked", project, tile, type)