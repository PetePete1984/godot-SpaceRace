extends Control

onready var Ship = get_node("HBoxContainer/ShipDisplay")
onready var ShipName = get_node("HBoxContainer/Stats/Name_Exp/ShipName")
onready var Experience

onready var Attack
onready var Shield
onready var Drive
onready var Scanner
onready var PowerTotal

onready var HullStrength
onready var PowerLeft
onready var Location
onready var ETA
onready var LocationSprite

func set_ship(ship):
	# set ship image
	# get permanent ship parameters
	# (ships should update these whenever their modules are changed)
	# extrapolate icons from parameters
	# draw ship stats
	# (ships should update these whenever their status changes)
	# get the ship's current location
	# if applicable, get the planet's sprite or sun sprite

	pass