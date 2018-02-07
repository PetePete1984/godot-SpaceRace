extends "res://Scripts/Model/Screen.gd"

onready var Border = get_node("Border")
onready var Flag = get_node("Flag")

onready var PlanetList = get_node("ScrollContainer/VBoxContainer")

signal system_clicked(system)
signal planet_clicked(planet)

#if tree.get_root() != null:
#    var child = tree.get_root().get_children()
#    while child != null:
#        # put code here
#        print(child.get_text(0))
#        child = child.get_next()

#for i in range (get_node("path/to/parent/node").get_child_count()):
#    get_node("path/to/parent/node").get_child(i).function_call()

func set_player(player):
	Flag.set_texture(TextureHandler.get_race_flag(player))
	PlanetList.set_planets(player)
	pass

func update():
	if is_visible():
		PlanetList.update()

func _ready():
	# TODO: use parameter to only update on show (minor minor minor change)
	connect("visibility_changed", self, "update")
	PlanetList.connect("system_clicked", self, "_on_system_clicked")
	PlanetList.connect("planet_clicked", self, "_on_planet_clicked")

func _on_system_clicked(system):
	emit_signal("system_clicked", system)

func _on_planet_clicked(planet):
	emit_signal("planet_clicked", planet)