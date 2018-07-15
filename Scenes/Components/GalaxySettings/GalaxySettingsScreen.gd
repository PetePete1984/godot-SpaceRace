extends "res://Scripts/Model/Screen.gd"

# entering this screen _always_ regenerates a new galaxy and resets all options
# BUT this new galaxy doesn't overwrite an existing one

signal galaxy_init(galaxy_options, race_key)
signal need_new_stars(size)

onready var next_screen = get_node("UI/NewGameAnchor/TextureButton")
onready var density_button = get_node("UI/DensityAnchor/Density")
onready var races_button = get_node("UI/RacesAnchor/Races")
onready var atmosphere_button = get_node("UI/AtmosphereAnchor/Atmosphere")

onready var settings_text = get_node("UI/GalaxySettingsAnchor/GalaxySettingsText")

onready var race_display = get_node("RaceDisplayAnchor/RaceDisplay")
onready var small_race_display = get_node("UI/NewGameAnchor/RacePortraitSmall")
onready var race_list = get_node("RaceListAnchor/RaceList")
onready var color_picker = get_node("UI/PlayerColorAnchor/PlayerColors")

onready var Galaxy3D = get_node("Galaxy3D")

var files = File.new()
var image_base_path = "res://Images/Screens/GalaxySettings"
var defaults = mapdefs.default_galaxy_settings

var current_settings = {}
var current_race = mapdefs.default_race
var current_color = mapdefs.default_color

func _ready():
	density_button.connect("pressed", self, "_on_density_button")
	races_button.connect("pressed", self, "_on_races_button")
	atmosphere_button.connect("pressed", self, "_on_atmosphere_button")
	
	race_list.connect("race_picked", self, "set_race")
	color_picker.connect("color_picked", self, "set_color")

	next_screen.connect("pressed", self, "init_new_galaxy")
	
	connect("need_new_stars", GameStateHandler, "generate_stars")
	GameStateHandler.connect("new_stars_generated", self, "repaint_galaxies")
	reset()
	
func reset():
	# TODO: scroll the container to the top
	for option in defaults:
		current_settings[option] = defaults[option]
	set_race(mapdefs.default_race)
	set_color(mapdefs.default_color)
	emit_signal("need_new_stars", current_settings.galaxy_size)
	density_button.update_button(current_settings["galaxy_size"])
	races_button.update_button(current_settings["races"])
	atmosphere_button.update_button(current_settings["atmosphere"])
	settings_text.update(current_settings)

func init_new_galaxy():
	emit_signal("galaxy_init", current_settings, current_race, current_color)
	
func repaint_galaxies(game_state):
	Galaxy3D.repaint(game_state)

func update_setting(list, setting, button):
	var current_option = current_settings[setting]
	var current_index = mapdefs[list].find(current_option)
	if current_index != -1:
		var new_index = current_index + 1
		if new_index >= mapdefs[list].size():
			new_index = 0
		var new_option = mapdefs[list][new_index]
		button.update_button(new_option)
		current_settings[setting] = new_option
		return new_option
	return current_option
	
func set_race(race_key):
	current_race = race_key
	color_picker.set_race(race_key)
	race_display.set_race(race_key)
	small_race_display.set_race(race_key)

func set_color(color):
	current_color = color
	color_picker.set_color(color)
	race_display.set_color(color)
	small_race_display.set_color(color)

# happens when density button is clicked
func _on_density_button():
	emit_signal("need_new_stars", update_setting("galaxy_sizes", "galaxy_size", density_button))
	settings_text.update(current_settings)
	pass
	
func _on_races_button():
	update_setting("race_range", "races", races_button)
	settings_text.update(current_settings)
	pass

func _on_atmosphere_button():
	update_setting("atmospheres", "atmosphere", atmosphere_button)
	settings_text.update(current_settings)
	pass
	
