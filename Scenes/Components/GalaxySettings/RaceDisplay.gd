extends Node2D

onready var race_name = get_node("RaceName")
onready var portrait = get_node("RacePortrait")
onready var homeplanet = get_node("RaceHomePlanet")
onready var race_flag = get_node("RaceFlag")
onready var race_desc = get_node("RaceDescription")

onready var race_ring = portrait.get_node("RaceRing")

func set_race(race_key):
	var index = RaceDefinitions.races.find(race_key)
	var race = RaceDefinitions.race[race_key]
	
	race_name.set_text(race.race_name)
	portrait.set_texture(TextureHandler.get_race_icon(race_key))
	homeplanet.set_texture(TextureHandler.get_home_planet(race_key))
	race_flag.set_texture(TextureHandler.get_race_flag(race_key))
	
	race_desc.set_text(race.race_description)
	pass
	
func set_color(color):
	# FIXME: Find a way to set shader params without access to this? It won't be available later
	race_name.get_material().set_shader_param("Color", color)
	race_flag.set_modulate(color)
	race_ring.set_modulate(color)
	pass

func _ready():
	pass
