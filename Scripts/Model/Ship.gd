# Ship in Space class (maybe also ship in orbit, we'll see)

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
var location_planet
var location_system

var starlane
var starlane_target
var starlane_progress

# maaaaaybe store a position in battlescape space
var position

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
var module_count
# convenience list
var unique_modules

var experience
var experience_level

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
	pass

func has_invader():
	return has_module("invasion_module")
	pass

func update_stats(category = null):
	var drive_temp = 0
	for coords in modules:
		var tile = modules[coords]
		if tile != null:
			if tile.module_type != null:
				if tile.module_type.category == "drive":
					drive_temp += tile.module_type.strength
					drives.append(tile)
	drive = drive_temp
	pass

