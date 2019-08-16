extends TileMap

signal tile_clicked(cell, pos)
signal tile_right_clicked(cell, pos)
signal tile_hover_in(cell, pos)
signal tile_hover_out(cell, pos)

var previous_hover
var active = true

func _ready():
	set_process_unhandled_input(true)

func _on_visibility_changed():
	set_process_unhandled_input(is_visible())

func _unhandled_input(event):
	if not active:
		return
	if not is_visible():
		return
	
	if event.type == InputEvent.MOUSE_MOTION:
		var cell_pos = _get_cell(event)
		var cell = cell_pos[0]
		var pos = cell_pos[1]
		if previous_hover == null:
			emit_signal("tile_hover_in", cell, pos)
			previous_hover = pos
		elif previous_hover != pos:
			emit_signal("tile_hover_out", previous_hover.x, previous_hover.y)
			emit_signal("tile_hover_in", cell, pos)
			previous_hover = pos

	if event.type == InputEvent.MOUSE_BUTTON and event.pressed:
		var cell_pos = _get_cell(event)
		var cell = cell_pos[0]
		var pos = cell_pos[1]
		if event.button_index == BUTTON_LEFT:
			emit_signal("tile_clicked", cell, pos)
		elif event.button_index == BUTTON_RIGHT:
			emit_signal("tile_right_clicked", cell, pos)

func _get_cell(event):
	# this would've ignored the event position
	# var relative_mouse_pos = get_local_mouse_pos()
	# instead, we use the event: event global pos is 0, 0; event pos needs to be offset by tilemap global pos
	var relative_mouse_pos = event.pos - get_global_pos()
	var tilemap_pos = world_to_map(relative_mouse_pos)
	var cell = get_cellv(tilemap_pos)
	return [cell, tilemap_pos]