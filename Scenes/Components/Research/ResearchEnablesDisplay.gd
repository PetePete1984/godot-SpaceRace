extends VBoxContainer

onready var label = get_node("Label")
onready var image = get_node("CenterContainer/TextureFrame")

func _ready():
	label.set_text("")
	image.set_texture(null)
	pass

func set_project(project, type, player = null):
	if type == "Surface":
		label.set_text(BuildingDefinitions.building_defs[project].building_name)
		image.set_texture(TextureHandler.get_surface_building(project))
	elif type == "Orbital":
		if OrbitalDefinitions.orbital_defs[project].research_name != null:
			label.set_text(OrbitalDefinitions.orbital_defs[project].research_name)
		else:
			label.set_text(OrbitalDefinitions.orbital_defs[project].orbital_name)
		image.set_texture(TextureHandler.get_orbital_building(project, player))
		var scale = 1
		if OrbitalDefinitions.orbital_defs[project].research_ship_scale != null:
			scale = OrbitalDefinitions.orbital_defs[project].research_ship_scale
			image.set_scale(Vector2(scale, scale))
	elif type == "Tech":
		label.set_text(TechProjectDefinitions.project_defs[project].project_name)
		image.set_texture(TextureHandler.get_tech_project(project))
	elif type == "Ship_Module":
		label.set_text(ShipModuleDefinitions.ship_module_defs[project].ship_module_name)
		image.set_texture(TextureHandler.get_ship_module(project))
		