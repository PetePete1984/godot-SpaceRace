extends "res://Scripts/Model/Screen.gd"

# signals for the main screen
signal system_picked(sys)
signal next_requested
signal auto_requested(enable)
signal research_requested
signal planetlist_requested
signal shiplist_requested

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

# TODO: move these to their own script and feed it the galaxy anchor
# 3D Viewport controls
onready var left = get_node("BottomControls/Left")
onready var right = get_node("BottomControls/Right")
onready var up = get_node("BottomControls/Up")
onready var down = get_node("BottomControls/Down")
onready var zoom_in = get_node("BottomControls/ZoomIn")
onready var zoom_out = get_node("BottomControls/ZoomOut")
onready var reset = get_node("BottomControls/Reset")

onready var lanes = get_node("BottomControls/Lanes")
onready var influence = get_node("BottomControls/Influence")
onready var ships = get_node("BottomControls/Ships")
onready var colonies = get_node("BottomControls/Colonies")

# Game Variables

func _ready():
	Galaxy_Root.connect("system_picked", self, "_system_picked")
	
	PlanetsButton.connect("pressed", self, "_planetlist_requested")
	ShipsButton.connect("pressed", self, "_shiplist_requested")
	ResearchButton.connect("pressed", self, "_research_requested")
	SpecialAbilityButton.connect("pressed", self, "_special_ability_window")
	SpeciesButton.connect("pressed", self, "_species_requested")

	NextButton.connect("pressed", self, "_next_requested")
	AutoButton.connect("toggled", self, "_auto_toggled")
	TurnHandler.connect("auto_stopped", self, "_auto_aborted")
	connect_3d_controls()

func connect_3d_controls():
	left.connect("button_down", self, "_on_rotate_horizontal", [1])
	left.connect("button_up", self, "_on_rotate_horizontal", [0])
	right.connect("button_down", self, "_on_rotate_horizontal", [-1])
	right.connect("button_up", self, "_on_rotate_horizontal", [0])
	up.connect("button_down", self, "_on_rotate_vertical", [1])
	up.connect("button_up", self, "_on_rotate_vertical", [0])
	down.connect("button_down", self, "_on_rotate_vertical", [-1])
	down.connect("button_up", self, "_on_rotate_vertical", [0])
	zoom_in.connect("button_down", self, "_on_zoom", [-1])
	zoom_in.connect("button_up", self, "_on_zoom", [0])
	zoom_out.connect("button_down", self, "_on_zoom", [1])
	zoom_out.connect("button_up", self, "_on_zoom", [0])

	pass

func update_game_state(game_state):
	set_turn(game_state.turn)

func set_payload(payload):
	set_game_state(payload)

func set_game_state(game_state):
	set_turn(game_state.turn)
	Galaxy_Root.set_galaxy(game_state)
	
func set_color(color):
	Turns.set_color(color)
	
func set_turn(turn):
	Turns.set_turn(turn)
	TurnCounter.set_text("%05d" % turn)
	
func _system_picked(sys):
	_cancel_auto()
	emit_signal("system_picked", sys)
	
func _next_requested():
	_cancel_auto()
	emit_signal("next_requested")
	
func _planetlist_requested():
	_cancel_auto()
	emit_signal("planetlist_requested")
	
func _shiplist_requested():
	_cancel_auto()
	emit_signal("shiplist_requested")

func _research_requested():
	_cancel_auto()
	emit_signal("research_requested")
	
func _special_ability_window():
	_cancel_auto()
	
func _species_requested():
	_cancel_auto()

func _auto_toggled(pressed):
	emit_signal("auto_requested", pressed)

# this is a signal handler, which is why it doesn't send auto_toggled(false)
# otherwise it might end up calling itself
func _auto_aborted():
	AutoButton.set_pressed(false)

# this is only called on manual clicks, which is why it sends the auto_toggled(false) signal
func _cancel_auto():
	_auto_toggled(false)
	AutoButton.set_pressed(false)
	
# 3D control responders
# TODO: pass the axis in the connection, less functions
func _on_rotate_horizontal(direction):
	Galaxy_Root.spin_h_direction = direction
	pass

func _on_rotate_vertical(direction):
	Galaxy_Root.spin_v_direction = direction
	pass

func _on_zoom(direction):
	Galaxy_Root.zoom_direction = direction
	pass

func _on_reset():
	Galaxy_Root.reset_camera()
	pass

