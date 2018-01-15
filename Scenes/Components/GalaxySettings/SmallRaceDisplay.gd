extends Sprite

onready var race_ring = get_node("RaceRing")

func _ready():
	pass

func set_race(race_key):
	set_texture(TextureHandler.get_race_icon(race_key))
	pass
	
func set_color(color):
	race_ring.set_modulate(color)
	pass