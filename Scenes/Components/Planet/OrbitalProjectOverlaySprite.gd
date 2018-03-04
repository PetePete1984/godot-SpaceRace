extends Area2D
# TODO: unify with surfaceprojectoverlaysprite
onready var sprite = get_node("Sprite")

func _ready():
	sprite.set_material(sprite.get_material().duplicate())

func set_orbital_project(tilemap, project, player):
	if project != null:
		if project.type == "Orbital":
			# TODO: handle ships
			update_progress(project)
			var cell = tilemap.get_cellv(project.position)
			set_pos(tilemap.map_to_world(project.position))
			# TODO: probably better to use the classes
			if project.sub_type == null:
				# TODO: reset offset and scale
				sprite.set_texture(TextureHandler.get_orbital_building(project.project, player))
				sprite.set_offset(Vector2())
				sprite.set_scale(Vector2(1,1))
			else:
				var ship = project.resulting_ship
				TextureHandler.get_ship_for_planet(ship, sprite)
			var alpha_height = Utils.get_alpha_height(sprite.get_texture())
			sprite.get_material().set_shader_param("alpha_height", float(alpha_height))
			show()
		else:
			hide()
	else:
		hide()

func update_progress(project):
	if project != null:
		# TODO: handle ships, which have their own cost
		# ie put starting cost into the project, never worry about defs again
		var cost = OrbitalDefinitions.orbital_defs[project.project].cost
		var remaining = project.remaining_industry
		var progress = float(cost-remaining) / float(cost)
		sprite.get_material().set_shader_param("progress", progress)
		if progress >= 1.0:
			hide()
	else:
		hide()

func _mouse_enter():
	if is_visible():
		sprite.get_material().set_shader_param("hovering", true)

func _mouse_exit():
	if is_visible():
		sprite.get_material().set_shader_param("hovering", false)