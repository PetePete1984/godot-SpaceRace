extends "res://Scripts/Model/Screen.gd"

onready var ShipList = get_node("ScrollContainer/VBoxContainer")

signal view_ship_layout(ship)

func set_player(player):
	# TODO: find the total number of ships, allowed ships and the difference
	#Flag.set_texture(TextureHandler.get_race_flag(player))
	ShipList.set_ships(player)

func update():
	ShipList.update()

func _ready():
	connect("visibility_changed", self, "update")