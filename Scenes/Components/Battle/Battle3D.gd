extends Spatial

onready var anchor = get_node("battle_center")
onready var line_drawer = anchor.get_node("line_drawer")
onready var grid = anchor.get_node("Grid")
onready var camera = get_node("camera")

const SPIN_SPEED = 360/5
const ZOOM_SPEED = 2
const SCALE_FACTOR = 1
var DISPLAY_SCALE = Vector3(SCALE_FACTOR,SCALE_FACTOR,SCALE_FACTOR) #Vector3(0.2, 0.2, 0.2)

#var StarSystemGenerator = preload("res://Scripts/StarSystemGenerator.gd")

var Planet = preload("res://Scripts/Model/Planet.gd")
var Planetmap = preload("res://Scripts/Planetmap.gd")
#var SmallPlanetSprite = preload("res://Scenes/Components/Battle/SmallPlanetSprite.gd")
var BattlePick = preload("res://Scenes/Components/ClickableArea3D.gd")
var BillboardSprite3D = preload("res://Scenes/Components/BillboardSprite3D.tscn")

var sprites = []
var star_textures = {}
var planet_textures = {}

var spin_direction = 0
var zoom_direction = 0

signal battle_object_clicked(object)
signal battle_object_hover_begin(object)
signal battle_object_hover_end(object)

signal sprites_cleared
signal sprites_repainted
signal rotated
signal zoomed
signal reset
signal pivot_changed

func _ready():
	#randomize()
	#_create_random_system()
	set_process(true)
	pass
	
func _process(delta):
	if spin_direction != 0:
		rotate(delta, spin_direction)
	if zoom_direction != 0:
		zoom(delta, zoom_direction)
	pass

func rotate(delta, direction):
	if direction != 0:
		anchor.rotate_y(deg2rad(SPIN_SPEED*delta*direction))
		emit_signal("rotated")

func zoom(delta, direction):
	if direction != 0:
		camera.size += ZOOM_SPEED*delta*direction
		emit_signal("zoomed")
	
func display_grid(display = true):
	grid.set("geometry/visible", display)

func display_lines(display = true):
	line_drawer.set("geometry/visible", display)

func clear_display():
	# FIXME: clear sun sprite
	for spr in sprites:
		#print(spr.get_name())
		if spr.has_node("area"):
			#print(spr.get_node("area").get_signal_connection_list("clicked"))
			#spr.get_node("area").disconnect("battle_object_clicked", self, "battle_object_clicked")
			pass
		spr.hide()
		spr.call_deferred("queue_free")
		#spr.get_parent().remove_child(spr)
	sprites.clear()
	emit_signal("sprites_cleared")

func set_system(system):
	generate_starsystem_display(system)
	line_drawer.set_system(system)
	emit_signal("sprites_repainted")
	pass
	
func generate_starsystem_display(system):
	clear_display()
	var sys = system
	
	# get and draw the star
	var sun_sprite = BillboardSprite3D.instance()
	sun_sprite.depth_cue = false
	sun_sprite.set_texture(TextureHandler.get_star(system))
	sun_sprite.set_scale(DISPLAY_SCALE)
	sun_sprite.set_translation(Vector3())
	sun_sprite.translate(Vector3(0, mapdefs.system_default_y, 0))
	sun_sprite.set_name(system.system_name)
	anchor.add_child(sun_sprite)
		
	# draw the system's star lanes
	for l in sys.lanes:
		var lane = sys.lanes[l]
		var lane_sprite = BillboardSprite3D.instance()
		lane_sprite.depth_cue = false
		lane_sprite.set_texture(TextureHandler.get_starlane(lane))
		lane_sprite.set_scale(DISPLAY_SCALE)
		lane_sprite.set_translation(l)

		var connects_to
		for i in lane.connects:
			if i != sys:
				connects_to = i.system_name
		lane_sprite.set_name("Star Lane to %s" % [connects_to])
		anchor.add_child(lane_sprite)
		sprites.append(lane_sprite)
	
	# draw the system's planets
	# and assign them clickables
	for planet in sys.planets:
		var planet_sprite = get_clickable(TextureHandler.get_planet(planet, true), planet.position, planet.planet_name, planet)

		# FIXME: this drawing hack must be nicer later, when the list is implemented
		var has_owner = false
		if planet.owner != null:
			has_owner = true
		if has_owner:
			# TODO: if planet size doesn't match home sprite size, resize collision box
			# TODO: use colored outlines to show ownership (nah, lines are only for stuff in orbit?)
			planet_sprite.set_scale(Vector3(4,4,4))
		
		sprites.append(planet_sprite)

	for ship in system.ships:
		var ship_sprite = get_clickable(TextureHandler.get_ship(ship.owner, ship.size), ship.position, ship.ship_name, ship)
		sprites.append(ship_sprite)
	pass

func get_clickable(obj_texture, obj_position, obj_name, obj_as_signal_param):
	var new_sprite = BillboardSprite3D.instance()

	new_sprite.depth_cue = false
	new_sprite.set_translation(obj_position)
	new_sprite.set_scale(DISPLAY_SCALE)
	new_sprite.set_texture(obj_texture)

	# clickable area
	var area3d = BattlePick.new()
	area3d.set_monitorable(true)
	area3d.set_enable_monitoring(true)
	area3d.set_ray_pickable(true)
	area3d.set_name("area")
	
	# clickable area shape
	var collisionShape = CollisionShape.new()
	var collisionBox3d = BoxShape.new()
	
	# sprite size * math = area shape
	var sprite_x = new_sprite.get_texture().get_width()
	var sprite_y = new_sprite.get_texture().get_height()
	var unit_pixel_ratio = new_sprite.get_pixel_size()
	
	# divide by 2 because extents are doubled size
	collisionBox3d.set_extents(Vector3(sprite_x, sprite_y, 1) * unit_pixel_ratio / 2)

	collisionShape.set_shape(collisionBox3d)
	area3d.add_shape(collisionBox3d)
	area3d.add_child(collisionShape)
	
	# add collision area to object
	new_sprite.add_child(area3d)
	new_sprite.set_name(obj_name)
	
	# connect to area's click signal for object picking
	area3d.connect("clicked", self, "_on_battle_object_clicked", [obj_as_signal_param])
	area3d.connect("hover_begin", self, "_on_battle_object_hover_begin", [obj_as_signal_param])
	area3d.connect("hover_end", self, "_on_battle_object_hover_end", [obj_as_signal_param])
	
	# add object sprite to object anchor
	anchor.add_child(new_sprite)
	return new_sprite

func _on_battle_object_clicked(object):
	emit_signal("battle_object_clicked", object)

func _on_battle_object_hover_begin(object):
	emit_signal("battle_object_hover_begin", object)
	
func _on_battle_object_hover_end(object):
	emit_signal("battle_object_hover_end", object)

#func _create_random_system():
#	var sys = StarSystemGenerator.generate_system()
#	generate_starsystem_display(sys)
#	pass