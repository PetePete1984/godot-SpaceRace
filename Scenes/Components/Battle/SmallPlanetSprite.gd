extends Sprite3D
	
func set_small_planet(planet):
#	# short-circuit home planet lookup
#	if planet.owner != null:
#		if planet.colony != null:
#			if planet.colony.home == true:
#				set_texture(get_race_home_planet_texture(planet.owner.race.type))
#				return
	
	# small = true
	set_texture(TextureHandler.get_planet(planet, true))

# TODO: home planet lookup obsolete in small planet sprite
#func get_race_home_planet_texture(race_key):
#	var index = RaceDefinitions.races.find(race_key)
#	var path = "res://Images/Races/HomePlanets/smhome.shp_%02d.png" % [index + 1]
#	return load(path)