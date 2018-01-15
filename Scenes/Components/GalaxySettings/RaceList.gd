extends Node2D

onready var container = get_node("ScrollContainer/VBoxContainer")
var ringtexture

signal race_picked(race)

func _ready():
	ringtexture = TextureHandler.get_race_ring_neutral()
	populate_container()
	pass

func populate_container():
	for race_index in range(RaceDefinitions.races.size()):
		var race = RaceDefinitions.races[race_index]
		var ring = TextureButton.new()
		var icon = TextureFrame.new()
		ring.set_normal_texture(ringtexture)
		#icon.set_texture(get_texture_for_race(race_index))
		icon.set_texture(TextureHandler.get_race_icon(race))
		icon.set_draw_behind_parent(true)
		ring.add_child(icon)
		icon.set_pos(Vector2(5,5))
		ring.connect("pressed", self, "_race_picked", [race])
		container.add_child(ring)
	
func _race_picked(race):
	emit_signal("race_picked", race)