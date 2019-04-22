extends Spatial

onready var anchor = get_node("galaxy_center/star_anchor")
onready var line_anchor = get_node("galaxy_center/line_anchor")
onready var line_drawer = line_anchor.get_node("line_drawer")
onready var gizmo_anchor = get_node("galaxy_center/star_anchor")


const SPIN_SPEED = 360/5
const ZOOM_SPEED = 2
const SYSTEMS = 100

var DepthCue = preload("res://Scenes/Components/DepthCueSprite3D.gd")
var StarSprite = preload("GalaxyStarSprite.tscn")
var StarSystemGenerator = preload("res://Scripts/Generator/StarSystemGenerator.gd")

onready var camera = get_node("camera")

var sprites = []
var textures = {}

var spin_h_direction = 0
var spin_v_direction = 0
var zoom_direction = 0

signal system_picked(system)
signal system_hover_begin(system)
signal system_hover_end(system)

signal rotated
signal zoomed

func _fixed_process(delta):
	# this also rotates the collision shapes because they don't billboard
	# the sprites' would have to look at the camera
	# anchor.rotate_y(deg2rad(delta*SPIN_SPEED))
	pass
	
func rotate(delta, direction = 1):
	if is_visible() and direction != 0:
		#anchor.rotate_y(deg2rad(delta*SPIN_SPEED*direction))
		anchor.global_rotate(Vector3(0,1,0), deg2rad(delta*SPIN_SPEED*direction))
		line_anchor.global_rotate(Vector3(0,1,0), deg2rad(delta*SPIN_SPEED*direction))
		# TODO: notify group instead of emitting signal
		emit_signal("rotated")

func set_galaxy(game_state, interaction = true):
	var galaxy = game_state.galaxy
	generate_galaxy_display(galaxy, interaction)
	draw_lines(game_state)
	pass

func _ready():
	set_process(true)
	set_fixed_process(true)
	pass
	
func _process(delta):
	if spin_h_direction != 0:
		rotate_h(delta, spin_h_direction)
	if spin_v_direction != 0:
		rotate_v(delta, spin_v_direction)
	if zoom_direction != 0:
		zoom(delta, zoom_direction)
	pass

func rotate_h(delta, direction):
	rotate(delta, direction)
	pass

func rotate_v(delta, direction):
	if direction != 0:
		anchor.global_rotate(Vector3(1,0,0), deg2rad(delta*SPIN_SPEED*direction))
		line_anchor.global_rotate(Vector3(1,0,0), deg2rad(delta*SPIN_SPEED*direction))
		emit_signal("rotated")
	pass

func zoom(delta, direction):
	if direction != 0:
		camera.size += delta*ZOOM_SPEED*direction
		emit_signal("zoomed")
	pass

func reset_camera():
	emit_signal("rotated")
	emit_signal("zoomed")

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

func system_hover_begin(sys):
	var human_player = GameStateHandler.game_state.human_player
	var human_home = null
	for colony_key in human_player.colonies:
		var colony = human_player.colonies[colony_key]
		if colony.home == true:
			human_home = colony
	if human_home != null:
		var human_system = human_home.planet.system
		if sys != human_system:
			#print(GalaxyNavigator.get_route(human_system, sys))
			pass
	pass

func system_hover_end(sys):
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
	
func generate_galaxy_display(galaxy, interaction = true):
	clear_display()
	for sys in galaxy.systems:
		#var sys = galaxy.systems[s]
		var spr3d = get_clickable_sprite3D_for_system(sys)
		spr3d.set_translation(sys.position)
		connect("rotated", spr3d.star, "_on_update_pos")
		sprites.append(spr3d)
		pass
	pass

func generate_debug_display(interaction = true):
	clear_display()
	var used_star_names = []
	for i in range(SYSTEMS):
		_create_random_starsystem(used_star_names, i, interaction)

func _create_random_starsystem(used_star_names, i, interaction = true):
	var sys = StarSystemGenerator.generate_system(used_star_names, i)
	var space_pos = Utils.rand_v3_in_unit_sphere(1)
	var spr3d = get_clickable_sprite3D_for_system(sys, interaction)
	spr3d.set_translation(space_pos)
	anchor.add_child(spr3d)
	sprites.append(spr3d)
	pass