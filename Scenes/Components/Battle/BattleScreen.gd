extends "res://Scripts/Model/Screen.gd"

# imports
var Planet = preload("res://Scripts/Model/Planet.gd")
var Ship = preload("res://Scripts/Model/Ship.gd")

# 3D Display Elements
onready var battle_root = get_node("BattleViewport/Viewport/battle_root")
onready var battle_center = get_node("BattleViewport/Viewport/battle_root/battle_center")

# UI Elements
onready var star_name = get_node("TopButtons/Normal/Star Name")
onready var star_type = get_node("TopButtons/Normal/Star Type")
onready var star_sprite = get_node("TopButtons/Normal/Star")

# UI controls
onready var left = get_node("BottomButtons/Left")
onready var right = get_node("BottomButtons/Right")

# FIXME: these are technically zoom in and out controls
onready var up = get_node("BottomButtons/Up")
onready var down = get_node("BottomButtons/Down")

onready var radar = get_node("BottomButtons/Radar")
onready var grid = get_node("BottomButtons/Grid")

# signals
signal planet_picked(planet)
signal ship_picked(ship)
signal repainted

var current_system = null
var current_selection = null

func _ready():
	# TODO: unify rotation directions
	left.connect("button_down", self, "_on_rotate", [-1])
	left.connect("button_up", self, "_on_rotate", [0])
	right.connect("button_down", self, "_on_rotate", [1])
	right.connect("button_up", self, "_on_rotate", [0])

	up.connect("button_down", self, "_on_zoom", [-1])
	up.connect("button_up", self, "_on_zoom", [0])
	down.connect("button_down", self, "_on_zoom", [1])
	down.connect("button_up", self, "_on_zoom", [0])
	
	radar.connect("toggled", battle_root, "display_lines")
	grid.connect("toggled", battle_root, "display_grid")
	
	# this will break when I drill down to the planet
	#connect("visibility_changed", self, "_maybe_refresh")
	battle_root.connect("battle_object_clicked", self, "_on_battle_object_picked")
#	set_process(true)
	pass

func _process(delta):
	pass
	
func set_payload(payload):
	set_system(payload)

# TODO: update when returning from planet screen, for example because of colonies cheated in or ships entering / leaving orbit
func _maybe_refresh():
	# multiple possible entry points exist for the battle screen
	# 1: from the galaxy view, player clicked on a star system
	# 2: from the planet list, player clicked on the star
	# 3: from an event, ship entered a player system
	# 4: from an event, a hostile ship entered or still is in a player system
	if current_system != null:
		if is_visible() == true:
				set_system(current_system)
	pass

func set_system(system):
	# update 3D display
	battle_root.set_system(system)
	# update UI
	update_ui(system)
	current_system = system
	pass
	
func update_ui(system):
	star_name.set_text(system.system_name)
	star_type.set_text(system.star_type.capitalize())
	star_sprite.set_texture(TextureHandler.get_star(system))

func planet_clicked(planet):
	if current_selection == planet:
		emit_signal("planet_picked", planet)
	else:
		current_selection = planet
	pass

func ship_clicked(ship):
	pass
	
func _on_rotate(direction):
	battle_root.spin_direction = direction

func _on_zoom(direction):
	battle_root.zoom_direction = direction
	
func _on_battle_object_picked(object):
	if object extends Planet:
		planet_clicked(object)
	pass