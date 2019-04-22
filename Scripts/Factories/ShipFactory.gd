const Ship = preload("res://Scripts/Model/Ship.gd")
const ShipModuleTile = preload("res://Scripts/Model/ShipModuleTile.gd")
const ShipTemplate = preload("res://Scripts/Model/ShipTemplate.gd")

static func initialize_ship(size, modules, ship_name, player):
	var ship = Ship.new()
	ship.ship_name = ship_name
	ship.owner = player
	ship.size = size

	for position in modules:
		var module_type = modules[position]
		# TODO: give ship module tile an init with module name
		var module_tile = ShipModuleTile.new()
		module_tile.module_type = ShipModuleDefinitions.ship_module_defs[module_type]
		module_tile.phantom = module_type
		module_tile.previous_module = module_type
		ship.modules[position] = module_tile
	# FIXME: derive real stats
	ship.update_stats()
	ship.power = ship.maximum_power
	ship.shield = 20
	ship.maximum_shield = 20
	ship.lane_speed = 4
	return ship

static func get_design_from_template(template):
	var ship_size = template.ship_size
	var ship_modules = template.ship_modules
	var ship_name = template.ship_name
	var ship_design = {}

	for i in range(ship_modules.size()):
		var coords = ShipDefinitions.ship_size_templates[ship_size][i]
		var pos = Vector2(coords[0], coords[1])
		ship_design[pos] = ship_modules[i]

	var current_ship_design = {
		size = ship_size,
		modules = ship_design,
		ship_name = ship_name
	}
	return current_ship_design

# TODO: not sure if blueprint will be a string key, or a dict
static func get_design_from_blueprint(blueprint, player, mode = null):
	# mode = cheapest or strongest, can come from the blueprint or be overridden
	var chunk_list = ShipTemplate.chunks
	var parts_list = []
	var template = {
		ship_size = blueprint.size,
		ship_modules = {},
		ship_name = ""
	}

	var max_slots = ShipDefinitions[blueprint.size].num_slots
	var current_slots = 0
	var bp_chunks = blueprint.chunks
	var tags = {}
	var modules = []
	for chunk in bp_chunks:
		if chunk.has("tags"):
			for key in chunk.tags.keys():
				if tags.has(key):
					tags[key] = tags[key] + chunk.tags[key]
				else:
					tags[key] = chunk.tags[key]
				current_slots += chunk.tags[key]
		if chunk.has("modules"):
			for key in chunk.modules.keys():
				if chunk.modules[key] == -1:
					var remaining_slots = max_slots - current_slots
					for i in range(remaining_slots):
						modules.append(key)
						current_slots += 1
				else:
					for i in range(chunk.modules[key]):
						modules.append(key)
						current_slots += 1
	print("Slots in use: ", current_slots, " while available are ", max_slots)
	for key in tags.keys():
		# find all modules that match the tag as category or tag
		# remove all modules that the player can't use
		# sort by cost (asc = cheapest, desc = strongest)
		# pick first, if available
		# add the module to the parts list as often as the tag list wants it
		pass

	pass