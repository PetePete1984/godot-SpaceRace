extends VBoxContainer

onready var label = get_node("Label")
onready var image = get_node("CenterContainer/TextureFrame")

func _ready():
	label.set_text("")
	image.set_texture(null)
	pass

func set_project(project, type):
	if type == "Surface":
		label.set_text(BuildingDefinitions.building_defs[project].building_name)
		image.set_texture(TextureHandler.get_surface_building(project))
	elif type == "Orbital":
		label.set_text(OrbitalDefinitions.orbital_defs[project].orbital_name)
		image.set_texture(TextureHandler.get_orbital_building(project))
		