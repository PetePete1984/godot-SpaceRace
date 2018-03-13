extends "res://Scenes/Components/ClickableArea2D.gd"

onready var sprite = get_node("Sprite")

var tile_position

func _ready():
	pass

func set_ship(ship):
	TextureHandler.get_ship_for_planet(ship, sprite)
	update_ship(ship)

func update_ship(ship):
	set_enable_monitoring(ship.active)