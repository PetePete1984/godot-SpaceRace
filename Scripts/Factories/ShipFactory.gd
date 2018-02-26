const Ship = preload("res://Scripts/Model/Ship.gd")

static func initialize_ship(size, modules, ship_name, player):
	var ship = Ship.new()
	ship.ship_name = ship_name
	ship.owner = player
	ship.size = size
	# FIXME: derive real stats
	ship.shield = 20
	ship.maximum_shield = 20
	ship.drive = 20
	ship.lane_speed = 4
	return ship