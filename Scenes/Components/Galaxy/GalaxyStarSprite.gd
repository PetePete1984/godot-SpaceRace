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

func setup(system, signal_handler, game_state, interaction = true):
	var human_player = game_state.human_player

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
		area.connect("hover_begin", signal_handler, "system_hover_begin", [system])
		area.connect("hover_end", signal_handler, "system_hover_end", [system])
		
	#spr3d.set_name(system.system_name)
	
	# TODO: wait why depth cue on a star in the center of the place
	# add Depth Cueing
	star.set_script(DepthCue)
	
	# FIXME: this drawing hack must be nicer later
	var system_has_owner = false
	var system_has_home = false
	var system_has_player_home = false

	var owner = null
	var owner_planets = 0

	var owners = {}
	
	for planet in system.planets:
		# TODO: formalize planet / system ownership in game state, because it depends on amount and owners of colonies; can be multiple in one system
		if planet.owner != null:
			if not owners.has(planet.owner):
				owners[planet.owner] = 0
			owners[planet.owner] += 1

			if owners[planet.owner] > owner_planets:
				owner = planet.owner
				owner_planets = owners[planet.owner]

	if owner != null:
		if owner.home_colony.planet.system == system:
			# TODO: set correct flag texture in TH
			flag.set_texture(TextureHandler.get_race_flag(owner))
			# TODO: last condition may not be exactly correct
			if owner == human_player:
				flag.show()
			elif human_player.knowledge.systems[system] == true:
				flag.show()
			elif human_player.knowledge.races[owner.race.type] == true:
				flag.show()
			else:
				flag.hide()
		# TODO: color according to owner
		# TODO: apply star-rings
		# TODO: apply player knowledge to general visibility
		control.show()
	
	return star