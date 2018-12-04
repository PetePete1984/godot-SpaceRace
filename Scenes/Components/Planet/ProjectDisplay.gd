extends CenterContainer

onready var title = get_node("Stack/ProjectTitle")
onready var icon = get_node("Stack/ProjectIcon")
onready var days = get_node("Stack/ProjectDays")

func _ready():
	
	pass

func set_project(planet):
	var project
	if planet.colony:
		project = planet.colony.project

	if project != null:
		var type = project.type
		var time = -1
		if not project.continuous:
			if planet.colony.adjusted_industry > 0:
				time = ceil(float(project.remaining_industry) / float(planet.colony.adjusted_industry))
			if time > 0:
				days.set_text("%d days until completion" % time)
				days.show()
			else:
				days.hide()
		else:
			days.hide()
		
		# FIXME: distinguish project type
		# TODO: use proper type
		var project_name
		var project_texture
		if type == "Surface":
			project_name = BuildingDefinitions.building_defs[project.project].building_name
			project_texture = TextureHandler.get_surface_building(project.project)
		elif type == "Orbital":
			project_name = OrbitalDefinitions.orbital_defs[project.project].orbital_name
			project_texture = TextureHandler.get_orbital_building(project.project, planet.colony.owner)
		elif type == "Tech":
			project_name = TechProjectDefinitions.project_defs[project.project].project_name
			project_texture = TextureHandler.get_tech_project(project.project)

		title.set_text(project_name)
		icon.set_texture(project_texture)
	else:
		days.hide()
		icon.set_texture(null)
		title.set_text("No project")
	pass

func update_project():
	pass