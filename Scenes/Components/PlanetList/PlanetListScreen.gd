extends "res://Scripts/Model/Screen.gd"

onready var tree = get_node("Tree")
onready var list = get_node("ItemList")

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
	# pass in self to connect signals to handlers
	PlanetList.set_planets(player, self)
	pass

# TODO: when returning from a planet screen, update the list because the project might be changed

func _ready():
	pass

func _on_system_clicked(system):
	emit_signal("system_clicked", system)

func _on_planet_clicked(planet):
	emit_signal("planet_clicked", planet)