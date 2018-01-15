extends Spatial

onready var anchor = get_node("galaxy_center/star_anchor")
onready var line_anchor = get_node("galaxy_center/line_anchor")
onready var line_drawer = line_anchor.get_node("line_drawer")
onready var gizmo_anchor = get_node("galaxy_center/star_anchor")


const SPIN_SPEED = 360/5
const SYSTEMS = 100

var DepthCue = preload("res://Scenes/Components/DepthCueSprite3D.gd")
var StarSprite = preload("GalaxyStarSprite.tscn")
var StarSystemGenerator = preload("res://Scripts/StarSystemGenerator.gd")

onready var camera = get_node("camera")

var sprites = []
var textures = {}

signal system_picked(system)
signal rotated

func _fixed_process(delta):
	# this also rotates the collision shapes because they don't billboard
	# the sprites' would have to look at the camera
	# anchor.rotate_y(deg2rad(delta*SPIN_SPEED))
	pass
	
func rotate(delta, direction = 1):
	anchor.rotate_y(deg2rad(delta*SPIN_SPEED*direction))
	# TODO: notify group instead of emitting signal
	emit_signal("rotated")

func set_galaxy(game_state, interaction = true):
	var galaxy = game_state.galaxy
	generate_starsystem_display(galaxy, interaction)
	draw_lines(game_state)
	pass

func _ready():
	set_process(true)
	set_fixed_process(true)
	pass
	
func _process(delta):
	pass
	
func get_clickable_sprite3D_for_system(sys, interaction = true):
	var star_sprite = StarSprite.instance()
	anchor.add_child(star_sprite)
	# self = signal_handler for clicks
	star_sprite.setup(sys, self, interaction)
	return star_sprite
	pass
	
# TODO: needs a function to paint symbols
func draw_homes(galaxy):
	for s in galaxy.systems:
		var sys = galaxy.systems[s]
		var has_owner = false
		for planet_key in sys.planets:
			if sys.planets[planet_key].owner != null:
				has_owner = true
		if has_owner:
			#spr3d.set_scale(Vector3(4,4,4))
			pass
	pass
	
func draw_ships(galaxy):
	pass

# TODO: needs a function to draw lanes between planets
func draw_lines(game_state):
	if game_state.human_player != null:
		var player = game_state.human_player
		line_drawer.draw_lanes_for_player(game_state.galaxy, player)

# TODO: symbol and lane visibility has options and filters
# TODO: symbol and lane visibility has rules according to player knowledge
	
func system_clicked(sys):
	emit_signal("system_picked", sys)
	pass
	
func clear_display():
	for spr in sprites:
		# TODO: may be redundant
		if spr.has_node("area"):
			#spr.get_node("area").disconnect("clicked", self, "system_clicked")
			pass
		if spr.is_inside_tree():
			spr.hide()
		if spr.is_inside_tree():
			spr.call_deferred("queue_free")
	sprites.clear()
	
func generate_starsystem_display(galaxy, interaction = true):
	clear_display()
	for s in galaxy.systems:
		var sys = galaxy.systems[s]
		var spr3d = get_clickable_sprite3D_for_system(sys)
		spr3d.set_translation(s)
		connect("rotated", spr3d.star, "_on_update_pos")
		sprites.append(spr3d)
		pass
	pass

func generate_debug_display(interaction = true):
	clear_display()
	for i in range(SYSTEMS):
		_create_random_starsystem(i, interaction)

func _create_random_starsystem(i, interaction = true):
	var sys_gen = StarSystemGenerator.new()
	var sys = sys_gen.generate_system(i)
	var space_pos = Utils.rand_v3_in_unit_sphere(1)
	var spr3d = get_clickable_sprite3D_for_system(sys, interaction)
	spr3d.set_translation(space_pos)
	anchor.add_child(spr3d)
	sprites.append(spr3d)
	pass