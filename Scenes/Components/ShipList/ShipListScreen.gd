extends "res://Scripts/Model/Screen.gd"

onready var ShipList = get_node("ScrollContainer/VBoxContainer")

signal view_ship_layout(ship)
signal system_clicked(system)
signal planet_clicked(planet)
signal ship_clicked


func set_player(player):
	# TODO: find the total number of ships, allowed ships and the difference
	#Flag.set_texture(TextureHandler.get_race_flag(player))
	ShipList.set_ships(player)

func update():
	ShipList.update()

func _ready():
	connect("visibility_changed", self, "update")
	ShipList.connect("system_clicked", self, "_on_signal", ["system_clicked"])
	ShipList.connect("planet_clicked", self, "_on_signal", ["planet_clicked"])
	ShipList.connect("ship_clicked", self, "_on_signal", ["ship_clicked"])
	ShipList.connect("ship_right_clicked", self, "_on_signal", ["view_ship_layout"])

func _on_signal(object, signal_name):
	if object != null:
		emit_signal(signal_name, object)
	else:
		emit_signal(signal_name)