extends "res://Scripts/Model/Screen.gd"

onready var UI = get_node("UI")
onready var title = UI.get_node("Title")
onready var desc = UI.get_node("Description")
onready var hist = UI.get_node("History")
onready var flag = get_node("RaceFlag")
onready var portrait = get_node("RacePic")

signal start_game()

func _ready():
	get_node("OverlayButton").connect("pressed", self, "_start_game")
	pass

func _start_game():
	emit_signal("start_game")
	
func setup_display(galaxy_settings, race_key, color_key):
	var race = RaceDefinitions.race[race_key]
	# FIXME: entry seems to be missing sometimes, probably unparsed (maybe init empty)
	var flavor = ""
	if race.race_history.has(galaxy_settings.atmosphere):
		flavor = race.race_history[galaxy_settings.atmosphere]
	
	title.set_text("%s: %s" % [race.race_name, race.race_history.power])
	desc.set_text("%s" % race.race_history.intro + str(flavor))
	hist.set_text("%s" % race.race_history.text)
	
	flag.set_texture(TextureHandler.get_race_flag(race))
	flag.set_modulate(mapdefs.galaxy_colors[color_key])

	var small = false
	portrait.set_texture(TextureHandler.get_race_icon(race, small))
