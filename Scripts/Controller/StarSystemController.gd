const ColonyController = preload("res://Scripts/Controller/ColonyController.gd")
const ShipController = preload("res://Scripts/Controller/ShipController.gd")

static func colonize(planet, ship, position, name = null):
	ColonyController.colonize_planet(planet, ship.owner, position, name)
	ShipController.remove_modules("colonizer")

static func invade(planet, ship):
	pass

static func handle_object(battle_object):
	pass

static func move_in_system(battle_object):
	# differentiate by type (ship, projectile)
	pass

static func move_ship(ship):
	# get ship's movement distance per sub-turn (one burst of engine x drives)
	# engine capacity is max 5 "blocks" per 1 engine strength, which currently is 1 unit in 3d space
	# any move costs the engine's power drain, even if it's shorter than the engine's burst distance
	# TODO: if the distance is short and only one of x drives can fly it, only that one drive will be activated and only that drive's drain is applied. ugh
	var sub_turn_distance = ship.drive
	var current_power = ship.power
	
	# get distance to target
	var target = ship.command.target

	var target_vector = target - ship.position
	var total_distance = target_vector.length()
	var distance_chunk = target_vector.normalized()
	
	var required_distance = ceil(total_distance)
	var remaining_distance = required_distance

	var available_power = ship.power
	var reserved_power = 0

	# TODO: sort available drives by efficiency (distance / power)?
	var available_drives = ship.drives
	var required_drives = []

	for drive in available_drives:
		if remaining_distance <= 0:
			break
		if reserved_power <= available_power:
			if drive.module_type.power <= available_power - reserved_power:
				required_drives.append(drive)
				reserved_power += drive.module_type.power
				remaining_distance -= drive.module_type.strength
		else:
			break

	var movement_this_round = 0
	var power_use_this_round = 0

	for drive in required_drives:
		movement_this_round += drive.module_type.strength
		power_use_this_round += drive.module_type.power

	pass

static func move_projectile(projectile):
	pass