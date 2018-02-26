# Building on a Tile
extends Reference

# points to a building def
var type = null
#var building_name = ""
var automated = false
var active = false
var tilemap_x = 0
var tilemap_y = 0
var used_pop = 0

func reset():
	type = null
	#building_name = ""
	automated = false
	active = false
	used_pop = 0
	
func set(key):
	type = BuildingDefinitions.building_defs[key]
	#building_name = type.building_name
	active = true
	used_pop = type.used_pop