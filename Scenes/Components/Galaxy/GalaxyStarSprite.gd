extends Spatial

onready var anc = get_node("Anchor")
onready var flag = anc.get_node("Flag")
onready var star = anc.get_node("Star")
onready var area = star.get_node("Area")
onready var control = anc.get_node("ControlRing")
onready var sec_control = anc.get_node("SecondaryControlRing")
onready var selected = anc.get_node("SelectedRing")
onready var sec_selected = anc.get_node("SecondarySelectedRing")
onready var seen = anc.get_node("SeenRing")

var DepthCue = preload("res://Scenes/Components/DepthCueSprite3D.gd")

func _ready():
	pass

func setup(system, signal_handler, interaction = true):
	# small = true
	var texture = TextureHandler.get_star(system, true)
	star.set_texture(texture)
	
	if interaction == true:
		var sprite_x = star.get_texture().get_width()
		var sprite_y = star.get_texture().get_height()
		var unit_pixel_ratio = star.get_pixel_size()
		
		# divide by 2 because extents are doubled size
		#collisionBox3d.set_extents(Vector3(sprite_x, sprite_y, 1) * unit_pixel_ratio / 2)
	
		#collisionShape.set_shape(collisionBox3d)
		#area3d.add_shape(collisionBox3d)
		#area3d.add_child(collisionShape)
		#spr3d.add_child(area3d)
		# connect to area's picked signal
		area.connect("clicked", signal_handler, "system_clicked", [system])
	
	#spr3d.set_name(system.system_name)
	
	# add Depth Cueing
	star.set_script(DepthCue)
	
	# FIXME: this drawing hack must be nicer later
	var system_has_owner = false
	var system_has_home = false
	var owner
	
	for planet in system.planets:
		# TODO: formalize planet / system ownership in game state
		if planet.owner != null:
			system_has_owner = true
			owner = planet.owner
			if planet.colony.home == true:
				system_has_home = true
	if system_has_owner:
		if system_has_home:
			# TODO: set correct flag texture in TH
			flag.set_texture(TextureHandler.get_race_flag(owner))
			flag.show()
		else:
			flag.hide()
		# TODO: apply star-rings
		# TODO: apply player knowledge to visibility
		control.show()
	
	return star