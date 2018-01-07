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
	
func setup_display(galaxy_settings, race_key, color):
	var race = RaceDefinitions.race[race_key]
	# FIXME: entry seems to be missing sometimes, probably unparsed (maybe init empty)
	var flavor = ""
	if race.race_history.has(galaxy_settings.atmosphere):
		flavor = race.race_history[galaxy_settings.atmosphere]
	
	title.set_text("%s: %s" % [race.race_name, race.race_history.power])
	desc.set_text("%s" % race.race_history.intro + str(flavor))
	hist.set_text("%s" % race.race_history.text)
	
	var flag_path = "res://Images/Races/FlagsBW/raceflag.shp_%02d.png" % [race.index + 1]
	var pic_path = "res://Images/Races/Pictures/lgrace%02d/lgrace%02d.shp_1.png" % [race.index, race.index]

	var file = File.new()
	if file.file_exists(flag_path):
		flag.set_texture(load(flag_path))
		flag.set_modulate(color)
	else:
		print("flag not found")
	if file.file_exists(pic_path):
		portrait.set_texture(load(pic_path))
	else:
		print("portrait not found")