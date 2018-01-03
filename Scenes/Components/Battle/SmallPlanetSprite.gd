extends Sprite3D
	
func set_small_planet(planet):
	# small = true
	set_texture(TextureHandler.get_planet(planet, true))
