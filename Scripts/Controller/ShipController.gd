const BattleCommand = preload("res://Scripts/Model/BattleCommand.gd")

const BATTLE_OFFSET = Vector3(1, 1, 0)

static func leave_orbit(planet, ship):
	var system = planet.system
	var exit_position = planet.position + BATTLE_OFFSET.normalized()
	ship.position = exit_position
	ship.location_planet = null
	ship.location_system = system
	system.ships.append(ship)

static func attempt_orbit(planet, ship):
	# TODO: check planet ownership and prevent docking if orbital shields present on enemy planets
	var system = planet.system
	var slots = planet.orbitals
	var current_position = ship.position
	var free_slots = []

	for x in range(slots.size()):
		for y in range(slots[x].size()):
			var orbital = slots[x][y]
			if orbital.type == null:
				free_slots.append(orbital)
	
	if free_slots.size() > 0:
		var target = free_slots.front()
		target.orbiting_ship = ship
		ship.position = null
		ship.location_planet = planet
		system.ships.erase(ship)
		return true

	else:
		var exit_position = (ship.position - planet.position).normalized()
		ship.position = exit_position
		return false

static func enter_starlane(lane, ship):
	ship.position = null
	ship.location_planet = null
	var system = ship.location_system
	ship.location_system = null
	system.ships.erase(ship)
	ship.starlane_progress = 0.0
	ship.starlane = lane
	ship.starlane_target = lane.from_to(system)
	pass

static func exit_starlane(ship):
	if ship.starlane == null:
		return false
	else:
		if ship.starlane_progress >= 1.0:
			var arrives_in = ship.starlane_target
			var system_index = ship.starlane.connects.find(arrives_in)
			# TODO: evaluate putting all ships in the direction of the system's star
			var arrives_at = ship.starlane.positions[system_index] + BATTLE_OFFSET.normalized()
			arrives_in.ships.append(ship)
			ship.location_system = arrives_in
			ship.position = arrives_at
			pass
	pass

static func move_in_starlane(ship):
	var where = ship.starlane_progress * ship.starlane.length
	var move = ship.lane_speed * ship.owner.stats.starlane_factor
	var new_where = where + move
	var new_progress = (where + move) / ship.starlane.length
	ship.starlane_progress = new_progress
	pass

static func recharge_power(ship):
	ship.power = ship.maximum_power

static func remove_modules(ship, module_type, amount = 1):
	var remove = []
	for position in ship.modules:
		var module = ship.modules[position]
		if remove.size() < amount:
			if module.module_type.type == module_type:
				remove.append(position)
		else:
			break

	for position in remove:
		ship.modules.erase(position)

static func command_move_in_system(ship, target):
	var move_command = BattleCommand.new()
	move_command.command_type = BattleCommand.COMMAND.MOVE
	move_command.target = target
	ship.command = move_command

static func command_move_to_planet(ship, planet):
	var move_command = BattleCommand.new()
	move_command.command_type = BattleCommand.COMMAND.MOVE
	move_command.target = planet.position
	move_command.target_object = planet
	ship.command = move_command

static func command_move_to_starlane(ship, lane):
	var move_command = BattleCommand.new()
	move_command.command_type = BattleCommand.COMMAND.MOVE
	move_command.target = lane.positions[lane.connects.find(ship.location_system)]
	move_command.target_object = lane
	ship.command = move_command
