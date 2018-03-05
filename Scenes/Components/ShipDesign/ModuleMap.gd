extends "res://Scenes/Components/TileMapMouseInput.gd"

signal place_module(position)
signal remove_module(position)

var ModulePreview

func _ready():
	connect("tile_clicked", self, "_on_left_click")
	connect("tile_right_clicked", self, "_on_right_click")
	connect("tile_hover_in", self, "_on_hover_in")
	connect("tile_hover_out", self, "_on_hover_out")
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
	if module != null:
		var def = ShipModuleDefinitions.ship_module_defs[module]
		var index = def.index
		set_cellv(position, index)
	else:
		# reset cell to empty cell
		set_cellv(position, 0)
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

func _on_left_click(cell, pos):
	if cell != -1:
		# the signal responder will tell the map to update itself
		emit_signal("place_module", pos)

func _on_right_click(cell, pos):
	if cell != -1:
		emit_signal("remove_module", pos)
	
func _on_hover_in(cell, pos):
	if cell != -1:
		# highlight cell or draw module stuck to cursor
		if ModulePreview != null:
			ModulePreview.set_pos(map_to_world(pos))
			ModulePreview.show()
	else:
		# hide cursor
		if ModulePreview != null:
			ModulePreview.hide()		

func _on_hover_out(cell, pos):
	pass
