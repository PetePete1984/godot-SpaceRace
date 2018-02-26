extends Reference
# Orbital Tiles can hold a building (shipyard etc)
# an orbital building being built (orbital project)
# or a ship being built (ship project)
# or a ship being refitted (refit project)

# Orbital Tiles also decide what becomes usable in the system view when a planet is picked

var type = null
var automated = false
var active = false
var used_pop = 0

var orbiting_ship

var tilemap_x
var tilemap_y

func reset_orbital():
	type = null
	automated = false
	active = false
	used_pop = 0

func set_orbital(key):
	# TODO: handle ships
	type = OrbitalDefinitions.orbital_defs[key]
	active = true
	used_pop = type.used_pop