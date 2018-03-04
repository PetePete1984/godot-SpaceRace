extends TileMap

signal place_module(position)
signal remove_module(position)

var ModulePreview

func _ready():
	set_process_input(true)

func set_template(ship_size):
	if ShipDefinitions.ship_size_templates.has(ship_size):
		clear()
		var template = ShipDefinitions.ship_size_templates[ship_size]
		for pos in template:
			var x = pos[0]
			var y = pos[1]

			set_cell(x, y, 0)
	pass

func set_preview(module):
	#var def = ShipModuleDefinitions.ship_module_defs[module]
	if ModulePreview != null:
		ModulePreview.set_texture(TextureHandler.get_ship_module(module))
		ModulePreview.set_offset(Vector2(0, 9.5))

func set_module(position, module = null):
	var def = ShipModuleDefinitions.ship_module_defs[module]
	var index = def.index
	set_cellv(position, index)
	pass

# TODO: support loading functioning ships, ships with missing modules and swapping ship sizes
func set_modules(module_position_list):
	for position in module_position_list:
		var def = ShipModuleDefinitions.ship_module_defs[module_position_list[position]]
		var index = def.index
		# open cell gets replaces
		if get_cellv(position) == 0:
			set_cellv(position, index)
			# occupied cell looks for free cells
		else:
			# FIXME: kinda wasteful?
			var free_cells = get_used_cells()
			for cell in free_cells:
				if get_cellv(cell) == 0:
					set_cellv(cell, index)
					break
	pass

func _input(event):
	if event.type == InputEvent.MOUSE_MOTION:
		var cell_pos = _get_cell()
		var cell = cell_pos[0]
		var pos = cell_pos[1]
		if cell != -1:
			# highlight cell or draw module stuck to cursor
			if ModulePreview != null:
				ModulePreview.set_pos(map_to_world(pos))
				ModulePreview.show()
			pass
		else:
			# hide cursor
			if ModulePreview != null:
				ModulePreview.hide()
			pass

	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var cell_pos = _get_cell()
			var cell = cell_pos[0]
			var pos = cell_pos[1]
			if cell != -1:
				# TODO: add module stuck to cursor
				# the signal responder will tell the map to update itself
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