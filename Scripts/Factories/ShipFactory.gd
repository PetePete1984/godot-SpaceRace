const Ship = preload("res://Scripts/Model/Ship.gd")
const ShipModuleTile = preload("res://Scripts/Model/ShipModuleTile.gd")

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
	ship.shield = 20
	ship.maximum_shield = 20
	ship.lane_speed = 4
	return ship