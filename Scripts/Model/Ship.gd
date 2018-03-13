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
# recharged with repair modules
var shield
var maximum_shield

var scanner

var drive
var lane_speed

# convenience dict
var module_count
# convenience list
var unique_modules