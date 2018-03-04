extends TileMap

signal tile_clicked(x, y)
signal tile_hover_in(x, y)
signal tile_hover_out(x, y)

var previous_hover

func _ready():
	set_process_input(true)

func _on_visibility_changed():
	set_process_input(is_visible())

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var cell_pos = _get_cell()
		var cell = cell_pos[0]
		var pos = cell_pos[1]
		if previous_hover == null:
			emit_signal("tile_hover_in", pos.x, pos.y)
			previous_hover = pos
		elif previous_hover != pos:
			emit_signal("tile_hover_out", previous_hover.x, previous_hover.y)
			emit_signal("tile_hover_in", pos.x, pos.y)
			previous_hover = pos

	if event.type == InputEvent.MOUSE_BUTTON and event.pressed:
		var cell_pos = _get_cell()
		var cell = cell_pos[0]
		var pos = cell_pos[1]
		emit_signal("tile_clicked", pos.x, pos.y)

func _get_cell():
	var relative_mouse_pos = get_local_mouse_pos()
	var tilemap_pos = world_to_map(relative_mouse_pos)
	var cell = get_cellv(tilemap_pos)
	return [cell, tilemap_pos]