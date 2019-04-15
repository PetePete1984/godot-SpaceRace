extends Reference

#class StarSystem:
var star_type = "" # pick from list
var system_name = "Tonsberg" # pick from list

# system's index in the galaxy, for save/load purposes
var index
# TODO: planets should probably just be an array and each should store their own position
var planets = [] # list of v3, planet
# same goes for lane endpoints
var lanes = {} # list of v3, lane
# ships should be an array of ship IDs / instances
var ships = [] # list of v3, ship
# TODO: nebulae need work (original analysis)
var nebulae = {} # list of v3, nebula

# the system's position in the galaxy
var position = null
# the rotation that was applied while last viewing this system
var rotation = null
# the last used zoom level
var zoom = 1
# what the camera was pointed at when last viewing this system
var pivot = null
# how far the planets are rotated around the star (ie percentage of a rotation cycle, but technically orbits are different between planets)
var orbit = null