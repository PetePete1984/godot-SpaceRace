extends TileMap

signal place_module(module, pos)
signal remove_module(pos)

func set_template(ship_size):
	if ShipDefinitions.ship_size_templates.has(ship_size):
		clear()
		var template = ShipDefinitions.ship_size_templates[ship_size]
		for pos in template:
			var x = pos[0]
			var y = pos[1]

			set_cell(x, y, 0)
	pass

func set_module(position, module = null):
	pass

func set_modules(module_position_list):
	pass

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var relative_mouse_pos = get_local_mouse_pos()
		var tilemap_pos = world_to_map(relative_mouse_pos)
		var cell = get_cellv(tilemap_pos)
		if cell != -1:
			# highlight cell or draw module stuck to cursor
			pass
		else:
			# hide cursor
			pass

	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var cell_pos = _get_cell()
			var cell = cell_pos[0]
			var pos = cell_pos[1]
			if cell != -1:
				# TODO: add module stuck to cursor
				emit_signal("place_module", pos)
			pass
		elif event.button_index == BUTTON_RIGHT and event.pressed:
			var cell_pos = _get_cell()
			var cell = cell_pos[0]
			var pos = cell_pos[1]
			if cell != -1:
				emit_signal("remove_module", pos)
			pass
	pass

func _get_cell():
	var relative_mouse_pos = get_local_mouse_pos()
	var tilemap_pos = world_to_map(relative_mouse_pos)
	var cell = get_cellv(tilemap_pos)
	return [cell, tilemap_pos]