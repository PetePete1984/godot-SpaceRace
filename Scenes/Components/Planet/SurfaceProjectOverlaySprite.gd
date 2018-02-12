extends Area2D

onready var sprite = get_node("Sprite")

func set_project(tilemap, project):
	if project != null:
		update_progress(project)
		var cell = tilemap.get_cell(project.position.x, project.position.y)
		set_pos(tilemap.map_to_world(project.position))
		var index = BuildingDefinitions.building_types.find(project.project)
		var texture = tilemap.get_tileset().tile_get_texture(index)
		var alpha_height = Utils.get_alpha_height(texture)
		sprite.get_material().set_shader_param("alpha_height", float(alpha_height))
		sprite.set_texture(texture)
		show()
	else:
		hide()
	pass
	
func update_progress(project):
	if project != null:
		var cost = BuildingDefinitions.building_defs[project.project].cost
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