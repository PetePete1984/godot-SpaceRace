extends Node2D

onready var container = get_node("ScrollContainer/VBoxContainer")
onready var ringtexture = preload("res://Images/Races/Rings/racering.shp_8.png")

signal race_picked(race)

func _ready():
	populate_container()
	pass

func populate_container():
	for race_index in range(RaceDefinitions.races.size()):
		var race = RaceDefinitions.races[race_index]
		var ring = TextureButton.new()
		var icon = TextureFrame.new()
		ring.set_normal_texture(ringtexture)
		icon.set_texture(get_texture_for_race(race_index))
		icon.set_draw_behind_parent(true)
		ring.add_child(icon)
		icon.set_pos(Vector2(5,5))
		ring.connect("pressed", self, "_race_picked", [race])
		container.add_child(ring)
		
func get_texture_for_race(index):
	# TODO: preload textures
	return load("res://Images/Races/Icons/smrace%02d/smrace%02d.shp_1.png" % [index, index])
	
func _race_picked(race):
	emit_signal("race_picked", race)