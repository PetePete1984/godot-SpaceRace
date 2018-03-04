extends Sprite

func _ready():
	pass

func set_ship(ship):
	TextureHandler.get_ship_for_planet(ship, self)
