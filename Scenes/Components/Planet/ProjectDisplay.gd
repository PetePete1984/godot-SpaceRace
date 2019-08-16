extends VBoxContainer

onready var title = get_node("ProjectTitle")
onready var icon = get_node("ProjectIcon")
onready var days = get_node("ProjectDays")

func _ready():
	
	pass

func set_project(planet):
	var project
	var scale = Vector2(1.0, 1.0)
	var offset = Vector2(0, 0)
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
		# TODO: use proper type (ie Project.gd)
		var project_name
		var project_texture
		if type == "Surface":
			project_name = BuildingDefinitions.get_name(project.project)
			#project_name = BuildingDefinitions.building_defs[project.project].building_name
			project_texture = TextureHandler.get_surface_building(project.project)
		elif type == "Orbital":
			project_name = OrbitalDefinitions.get_name(project.project)
			#project_name = OrbitalDefinitions.orbital_defs[project.project].orbital_name
			if project.sub_type != null and project.sub_type.begins_with("Ship"):
				project_texture = TextureHandler.get_orbital_building(project, planet.colony.owner)
				if ShipDefinitions.drawing_scale_offset.has(project.resulting_ship.size):
					var offset_scale = ShipDefinitions.drawing_scale_offset[project.resulting_ship.size]
					offset = Vector2(offset_scale.offset_planet[0], offset_scale.offset_planet[1])
					scale = Vector2(offset_scale.scale_planet, offset_scale.scale_planet)

			else:
				project_texture = TextureHandler.get_orbital_building(project.project, planet.colony.owner)
		elif type == "Tech":
			project_name = TechProjectDefinitions.get_name(project.project)
			#project_name = TechProjectDefinitions.project_defs[project.project].project_name
			project_texture = TextureHandler.get_tech_project(project.project)

		title.set_text(project_name)
		#icon.set_scale(scale)
		#icon.set_offset(offset)
		icon.set_texture(project_texture)
	else:
		days.hide()
		#icon.set_scale(Vector2(1.0, 1.0))
		#icon.set_offset(Vector2(0, 0))
		icon.set_texture(null)
		title.set_text("No project")
	pass

func update_project():
	pass