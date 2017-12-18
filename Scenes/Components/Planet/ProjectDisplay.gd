extends CenterContainer

onready var title = get_node("Stack/ProjectTitle")
onready var icon = get_node("Stack/ProjectIcon")
onready var days = get_node("Stack/ProjectDays")

const image_base_path = "res://Images/Screens/Planet/Buildings"

func _ready():
	
	pass

func set_project(planet):
	var project = planet.colony.project
	if project != null:
		var type = project.type
		var time = -1
		# TODO: account for projects without a cost
		if planet.colony.adjusted_industry > 0:
			time = ceil(project.remaining_industry / planet.colony.adjusted_industry)
		if time > 0:
			days.set_text("%d days until completion" % time)
			days.show()
		else:
			days.hide()
		
		title.set_text(BuildingDefinitions.building_defs[project.building].building_name)
		var building_index = BuildingDefinitions.building_types.find(project.building)
		var path = "%s/%s/%02d_%s.png" % [image_base_path, type, building_index+1, project.building]
		icon.set_texture(load(path))
	else:
		days.hide()
		icon.set_texture(null)
		title.set_text("No project")
	pass

func update():
	pass