extends "res://Scripts/Model/Screen.gd"

# signals for the main screen
signal system_picked(sys)
signal next_requested
signal auto_requested(enable)
signal research_requested
signal planetlist_requested

# Display Elements
onready var Galaxy3D = get_node("Galaxy3D")
onready var Galaxy_Root = Galaxy3D.get_node("Viewport/galaxy_root")

# UI Elements
onready var TurnCounter = get_node("UI/TurnPanel/TurnLabel")
onready var Turns = get_node("UI/TurnAnchor/Turns")

# UI Clickables
onready var NextButton = get_node("UI/Next")
onready var AutoButton = get_node("UI/Auto")
onready var PlanetsButton = get_node("UI/Planets")
onready var ShipsButton = get_node("UI/Ships")
onready var ResearchButton = get_node("UI/Research")
onready var SpecialAbilityButton = get_node("UI/Special")
onready var SpeciesButton = get_node("UI/Species")

# Game Variables

func _ready():
	Galaxy_Root.connect("system_picked", self, "_system_picked")
	
	PlanetsButton.connect("pressed", self, "_planetlist_requested")
	ResearchButton.connect("pressed", self, "_research_requested")

	NextButton.connect("pressed", self, "_next_requested")
	AutoButton.connect("toggled", self, "_auto_toggled")
	SpecialAbilityButton.connect("pressed", self, "_special_ability_window")
	TurnHandler.connect("auto_stopped", self, "_auto_aborted")
	pass

func _system_picked(sys):
	emit_signal("system_picked", sys)
	
func _next_requested():
	emit_signal("next_requested")
	
func _research_requested():
	emit_signal("research_requested")
	
func _planetlist_requested():
	emit_signal("planetlist_requested")

func _special_ability_window():
	pass
	
func _auto_toggled(pressed):
	emit_signal("auto_requested", pressed)
	
func _auto_aborted():
	AutoButton.set_pressed(false)
	
func update_game_state(game_state):
	set_turn(game_state.turn)
	pass

func set_payload(payload):
	set_game_state(payload)

func set_game_state(game_state):
	var galaxy = game_state.galaxy
	set_turn(game_state.turn)
	Galaxy_Root.set_galaxy(galaxy)
	pass
	
func set_color(color):
	Turns.set_color(color)
	
func set_turn(turn):
	Turns.set_turn(turn)
	TurnCounter.set_text("%05d" % turn)