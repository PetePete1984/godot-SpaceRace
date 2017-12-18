extends Reference

#class StarSystem:
var star_type = "" # pick from list
var system_name = "Tonsberg" # pick from list
var planets = {} # list of v3, planet
var lanes = {} # list of v3, lane
var ships = {} # list of v3, ship
var nebulae = {} # list of v3, nebula

# the system's position in the galaxy
var position = null
# the rotation that was applied while last viewing this system
var rotation = null
# the last used zoom level
var zoom = 1
# what the camera was pointed at when last viewing this system
var pivot = null
# how far the planets are rotated around the star
var orbit = null