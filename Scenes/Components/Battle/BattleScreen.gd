extends "res://Scripts/Model/Screen.gd"

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
onready var radar = get_node("BottomButtons/Radar")
onready var grid = get_node("BottomButtons/Grid")

# signals
signal planet_picked(planet)
signal ship_picked(ship)
signal repainted

# interaction variables
var holding_dir = 0

var current_system = null

func _ready():
	left.connect("button_down", self, "set_rotate", [-1])
	left.connect("button_up", self, "set_rotate", [0])
	right.connect("button_down", self, "set_rotate", [1])
	right.connect("button_up", self, "set_rotate", [0])
	
	radar.connect("toggled", battle_root, "display_lines")
	grid.connect("toggled", battle_root, "display_grid")
	
	# this will break when I drill down to the planet
	#connect("visibility_changed", self, "_maybe_refresh")
	battle_root.connect("battle_object_clicked", self, "_on_battle_object_picked")
	set_process(true)
	pass

func _process(delta):
	if holding_dir != 0:
		battle_center.rotate_y(deg2rad(battle_root.SPIN_SPEED * holding_dir * delta))
	pass
	
func set_payload(payload):
	set_system(payload)
	
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
	
func set_rotate(arg):
	holding_dir = arg
	pass
	
func _on_battle_object_picked(object):
	if "planet_name" in object:
		#print(object.planet_name)
		emit_signal("planet_picked", object)
	pass