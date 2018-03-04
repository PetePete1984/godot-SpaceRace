extends Node
var ShipDef = preload("res://Scripts/Model/ShipDef.gd")

var ship_types = ["small", "medium", "large", "enormous"]

var ship_defs = {
	"small": {
		cost = 70
	},
	"medium": {
		cost = 170
	},
	"large": {
		cost = 240
	},
	"enormous": {
		cost = 410
	}
}

# TODO: the original might have scale factors for all race / ship size combinations
var drawing_scale_offset = {
	"small": {
		"scale_planet": 0.5,
		"offset_planet": [-6, 11]
	},
	"medium": {
		"scale_planet": 0.5,
		"offset_planet": [-5, 11]
	}
}

# TODO: try reordering by Y coordinate (or just sorting on load)

var ship_size_templates = {
	"small": [
		[6, -4],
		[9, 0],
		[9, 6],
		[9, 9],
		[14, 3]
	],
	"medium": [
		[6, -4],
		[7, -2],
		[9, 9],
		[10, -1],
		[10, 7],
		[11, 6],
		[12, 1],
		[12, 3],
		[12, 4],
		[12, 5]
	],
	"large": [
		[6, -4],
		[7, -3],
		[8, -2],
		[8, 6],
		[8, 8],
		[9, 7],
		[9, 9],
		[10, -1],
		[10, 4],
		[10, 5],
		[11, 0],
		[11, 2],
		[11, 3],
		[11, 6],
		[13, 4]
	],
	"enormous": [
		[6, -4],
		[7, -4],
		[7, -3],
		[7, -2],
		[7, 7],
		[9, -2],
		[9, -1],
		[9, 0],
		[9, 5],
		[9, 6],
		[9, 7],
		[9, 8],
		[9, 9],
		[11, 0],
		[11, 1],
		[11, 2],
		[11, 4],
		[11, 5],
		[11, 6],
		[11, 7],
		[12, 3],
		[13, 2],
		[13, 4],
		[13, 5],
		[14, 3]
	]
}

func _ready():
	for s in ship_types:
		var data = ship_defs[s]
		var def = ShipDef.new()
		def.size = s
		for key in data:
			def[key] = data[key]

		for slot in ship_size_templates[s]:
			def.slots.append(slot)

		def.num_slots = def.slots.size()