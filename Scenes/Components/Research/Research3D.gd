extends Spatial

var BillboardSprite3D = preload("res://Scenes/Components/BillboardSprite3D.tscn")

onready var research_center = get_node("research_center")
onready var sprites_anchor = research_center.get_node("sprites_anchor")
onready var line_drawer = research_center.get_node("LineDrawer")

var ResearchPick = preload("res://Scenes/Components/ClickableArea3D.gd")

var rings = {
	"active": preload("res://Images/Screens/Research/Rings/active.png"),
	"highlight": preload("res://Images/Screens/Research/Rings/highlight.png"),
	"normal": preload("res://Images/Screens/Research/Rings/normal.png"),
	"red": preload("res://Images/Screens/Research/Rings/red.png")
}
var res_sprites = []

# rotation of the tree
signal rotated
# mouse pick
signal research_selected(player, research)
# mouse over
signal research_enter(player, research)
signal research_exit(player, research)

# TODO: temp
var dummyplayer = {
	"research": {
		"spectral_analysis": {
			"progress": 0.5
		}
	},
	"completed_research": ["xenobiology", "orbital_structures"]
}

func _ready():
	#show_research(dummyplayer)
	#set_process(true)
	pass
	
func _process(delta):
	research_center.rotate_y(deg2rad(20*delta))
	emit_signal("rotated")
	
func clear_screen():
	for s in sprites_anchor.get_children():
		s.hide()
		s.call_deferred("queue_free")
	_clear_lines()
	pass

func show_research(player):
	clear_screen()
	# research definitions tell the screen what research is available
	# a player's research progress decides what icons are visible or completed
	# a player's current research project decides what icon is shown as "in progress" = "growing"
	# a player's total research points change information about project length
	var defs = ResearchDefinitions.research_defs
	for key in defs:
		var research = defs[key]
		
		var research_ring = BillboardSprite3D.instance()
		# TODO: take research status into account
		research_ring.set_texture(rings.normal)
		
		var area3d = Area.new()
		### picking
		area3d.set_script(ResearchPick)
		area3d.set_monitorable(true)
		area3d.set_enable_monitoring(true)
		area3d.set_ray_pickable(true)
		area3d.set_name("area")
		var collisionShape = CollisionShape.new()
		var collisionBox3d = BoxShape.new()
		
		var sprite_x = research_ring.get_texture().get_width()
		var sprite_y = research_ring.get_texture().get_height()
		var unit_pixel_ratio = research_ring.get_pixel_size()
		
		# divide by 2 because extents are doubled size
		collisionBox3d.set_extents(Vector3(sprite_x, sprite_y, 1) * unit_pixel_ratio / 2)
		collisionShape.set_shape(collisionBox3d)
	
		area3d.add_shape(collisionBox3d)
		area3d.add_child(collisionShape)
		research_ring.add_child(area3d)
		area3d.connect("clicked", self, "_on_research_clicked", [player, key])
		# TODO: may be possible to use mouse_enter and mouse_exit signals
		area3d.connect("hover_begin", self, "_on_research_enter", [player, key])
		area3d.connect("hover_end", self, "_on_research_exit", [player, key])
		###
		
		var research_icon = BillboardSprite3D.instance()
		# disable depth cue on the image, otherwise it's modulated twice
		research_icon.depth_cue = false
		# get research image
		
		var path = "res://Images/Screens/Research/Research/restree.shp_%02d.png" % (research.index+1)
		if File.new().file_exists(path):
			research_icon.set_texture(load(path))
		
		if not research.type in player.completed_research:
			if player.research.has(research.type):
				research_icon.set_scale(Vector3(1,1,1) * player.research[research.type].progress())
			else:
				research_icon.set_scale(Vector3(0,0,0))
		
		# TODO: find out how to set research sprite material to always on top (in front of lines)
		research_ring.add_child(research_icon)
		research.position[0] = randi() % 20 - 10
		#research.position[1] *= 
		research.position[2] = randi() % 20 - 10
		var position = _arr_to_v3(research.position, true)
		research_ring.set_translation(position)
		research_ring.set_scale(Vector3(6,6,6))
		sprites_anchor.add_child(research_ring)
		
		# TODO: research that has been completed needs to be shown, always
		if research.type in player.completed_research:
			research_ring.show()
		elif research.requires.size() > 0:
			var all_fulfilled = true
			for req in research.requires:
				var require = defs[req]
				if not require.type in player.completed_research:
					all_fulfilled = false
					break
			if all_fulfilled:
				research_ring.show()
			else:
				research_ring.hide()
		else:
			research_ring.show()
			
		connect("rotated", research_ring, "_on_update_pos")
		

	# get list of visible connections
	var connections = []
	for key in defs:
		var research = defs[key]
		if research.requires.size() > 0:
			var fulfilled_reqs = []
			for req in research.requires:
				var requirement = defs[req]
				if requirement.type in player.completed_research:
					fulfilled_reqs.append(requirement.type)

			if fulfilled_reqs.size() == research.requires.size():
				for fr in fulfilled_reqs:
					var connects_to = defs[fr]
					var pair = [research.position, connects_to.position]
					connections.append(pair)
	
	
	for c in connections:
		_draw_line(c[0], c[1], true)
	pass
	
func _draw_line(from, to, invert_y = false):
	var d = line_drawer
	d.begin(Mesh.PRIMITIVE_LINES, null)
	d.add_vertex(_arr_to_v3(from, invert_y))
	d.add_vertex(_arr_to_v3(to, invert_y))
	d.end()

func _clear_lines():
	line_drawer.clear()

func _arr_to_v3(array, invert_y = false):
	if array.size() != 3:
		print("invalid array fed to arr2v3")
		return null
	else:
		var result = Vector3(array[0], array[1], array[2])
		if invert_y:
			result.y *= -1
		return result

func _on_research_clicked(player, research):
	emit_signal("research_selected", player, research)
	
func _on_research_enter(player, research):
	emit_signal("research_enter", player, research)
	
func _on_research_exit(player, research):
	emit_signal("research_exit", player, research)