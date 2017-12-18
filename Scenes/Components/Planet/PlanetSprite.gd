extends Sprite

func set_planet(planet):
	set_texture(TextureHandler.get_planet(planet))
	update()