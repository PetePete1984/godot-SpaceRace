# Ship in Space class (maybe also ship in orbit, we'll see)

signal position_changed(old, new)
signal arrived()
signal docked()
signal undocked()
signal left_system()
signal entered_system()

var ship_name
# TODO: get rid of references when cleaning up
var owner

# small, medium, large, enormous
var size

# ships in construction aren't active
var active = false

# probably will do a vector2, moduletile dict this time
var modules = {}

# template used to build this ship, used for refitting
var template
# modules on a ship before it was fed into an orbital dock?
var previous_modules

# maaaaybe store a general location
var location_planet setget _set_location_planet
var location_system

var starlane setget _set_starlane
var starlane_target
var starlane_progress

# maaaaaybe store a position in battlescape space
var position setget _set_position

# most recent command
var command
# if a movement command was issued and unfinished (maybe stick that in the command)
var target

# all derived from modules
# recharges every turn
var power
var maximum_power

# TODO: might need to be hull strength and shield separated
# TODO: shields are module and each is individual?
# recharged with repair modules
var shield
var maximum_shield

var scanner

# total drive speed
var drive
# list of drives, ordered by speed?
var drives = []
# total starlane speed
var lane_speed

# convenience dict
var module_count = {}
# convenience list
var unique_modules = []

var experience = 0
var experience_level = 0

func has_module(module):
	var result = false
	for coords in modules:
		var tile = modules[coords]
		if tile != null:
			if tile.module_type != null:
				if tile.module_type.type == module:
					result = true
					break

	return result

func has_colonizer():
	return has_module("colonizer")

func has_invader():
	return has_module("invasion_module")

func update_stats(category = null):
	var drive_temp = 0
	var power_temp = 0
	# clear convenience lists
	drives = []
	unique_modules = []
	module_count = {}

	for coords in modules:
		var tile = modules[coords]
		if tile != null:
			if tile.module_type != null:
				if tile.module_type.category == "drive":
					drive_temp += tile.module_type.strength
					drives.append(tile)
				if tile.module_type.category == "generator":
					power_temp += tile.module_type.power
				if not tile.module_type.type in unique_modules:
					unique_modules.append(tile.module_type.type)
				if not module_count.has(tile.module_type.type):
					module_count[tile.module_type.type] = 0
				module_count[tile.module_type.type] += 1
	drive = drive_temp
	maximum_power = power_temp
	#print(inst2dict(self))
	pass

func _set_position(new_position):
	if position != new_position:
		if new_position == null:
			# TODO: check if this is the correct behavior
			position = new_position
			emit_signal("arrived")
		else:
			var old_position = position
			position = new_position
			emit_signal("position_changed", old_position, position)

func _set_location_planet(planet):
	location_planet = planet
	if position == null:
		emit_signal("docked")
		emit_signal("left_system")
	else:
		if location_planet == null:
			emit_signal("undocked")
			emit_signal("entered_system")

func _set_starlane(lane):
	starlane = lane
	if starlane == null:
		emit_signal("entered_system")
	else:
		emit_signal("left_system")