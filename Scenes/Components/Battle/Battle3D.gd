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
var SmallPlanetSprite = preload("res://Scenes/Components/Battle/SmallPlanetSprite.gd")
var BattlePick = preload("res://Scenes/Components/ClickableArea3D.gd")
var BillboardSprite3D = preload("res://Scenes/Components/BillboardSprite3D.tscn")

var sprites = []
var star_textures = {}
var planet_textures = {}

var spin_direction = 0
var zoom_direction = 0

signal battle_object_clicked(object)
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
	anchor.rotate_y(deg2rad(SPIN_SPEED*delta*direction))
	emit_signal("rotated")

func zoom(delta, direction):
	camera.size += ZOOM_SPEED*delta*direction
	emit_signal("zoomed")
	
func display_grid(display = true):
	grid.set("geometry/visible", display)

func display_lines(display = true):
	line_drawer.set("geometry/visible", display)

func clear_display():
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
	var image_index = mapdefs.stars.find(sys.star_type)
	if image_index != -1:
		# TODO: Use BillboardSprite
		var spr3d = Sprite3D.new()
		var path = "res://Images/Screens/Battle/Suns/%02d_%s.png" % [image_index+1, sys.star_type]
		
		if star_textures.has(image_index):
			spr3d.set_texture(star_textures[image_index])
		elif File.new().file_exists(path):
			var texture = load(path)
			spr3d.set_texture(texture)
			star_textures[image_index] = texture

		spr3d.set_translation(Vector3(0, 0, 0))
		spr3d.translate(Vector3(0, mapdefs.system_default_y, 0))
		
		spr3d.set_flag(GeometryInstance.FLAG_BILLBOARD, true)
		spr3d.set_scale(DISPLAY_SCALE)
		spr3d.set_name(sys.system_name)
		# FIXME: why is flip h required?
		spr3d.set_flip_h(true)
		anchor.add_child(spr3d)
		sprites.append(spr3d)
		
	# draw the system's star lanes
	for l in sys.lanes:
		var lane = sys.lanes[l]
		var l3d = Sprite3D.new()
		l3d.set_translation(l)
		l3d.set_flag(GeometryInstance.FLAG_BILLBOARD, true)
		l3d.set_scale(DISPLAY_SCALE)
		l3d.set_texture(load("res://Images/Screens/Battle/Lanes/%s.png" % [lane.type]))
		l3d.set_flip_h(true)
		var connects_to
		for i in lane.connects:
			if i != sys:
				connects_to = i.system_name
		l3d.set_name("Star Lane to %s" % [connects_to])
		anchor.add_child(l3d)
		sprites.append(l3d)
	
	# draw the system's planets
	# and assign them clickables
	for p in sys.planets:
		var planet = sys.planets[p]
		var p3d = SmallPlanetSprite.new()
		p3d.set_translation(p)
		p3d.set_flag(GeometryInstance.FLAG_BILLBOARD, true)
		p3d.set_scale(DISPLAY_SCALE)
		p3d.set_small_planet(planet)
		# FIXME: why is flip h required?
		p3d.set_flip_h(true)
		# clickable area
		var area3d = Area.new()
		area3d.set_script(BattlePick)
		area3d.set_layer_mask(1)
		area3d.set_monitorable(true)
		area3d.set_enable_monitoring(true)
		area3d.set_ray_pickable(true)
		area3d.set_name("area")
		
		# clickable area shape
		var collisionShape = CollisionShape.new()
		var collisionBox3d = BoxShape.new()
		
		# sprite size * math = area shape
		var sprite_x = p3d.get_texture().get_width()
		var sprite_y = p3d.get_texture().get_height()
		var unit_pixel_ratio = p3d.get_pixel_size()
		
		# divide by 2 because extents are doubled size
		collisionBox3d.set_extents(Vector3(sprite_x, sprite_y, 1) * unit_pixel_ratio / 2)
	
		collisionShape.set_shape(collisionBox3d)
		area3d.add_shape(collisionBox3d)
		area3d.add_child(collisionShape)
		
		# add collision area to planet
		p3d.add_child(area3d)
		p3d.set_name(planet.planet_name)
		
		# connect to area's click signal
		area3d.connect("clicked", self, "_on_battle_object_clicked", [planet])
		
		# add planet sprite to planet anchor
		anchor.add_child(p3d)
		# FIXME: this drawing hack must be nicer later
		var has_owner = false
		if planet.owner != null:
			has_owner = true
		if has_owner:
			# TODO: if planet size doesn't match home sprite size, resize collision box
			p3d.set_scale(Vector3(4,4,4))
		
		sprites.append(p3d)
	pass

func _on_battle_object_clicked(object):
	emit_signal("battle_object_clicked", object)

#func _create_random_system():
#	var sys = StarSystemGenerator.generate_system()
#	generate_starsystem_display(sys)
#	pass