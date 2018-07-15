# Sprite3D that darkens when moved globally and displays a radar line pointing towards y = 0
# TODO: Depth cueing could probably be done in a shader
extends Sprite3D

export var depth_cue = true
export var radar_line = false

onready var radar_geo = get_node("radar_line")

var assigned_battle_object

func _ready():
	_on_update_pos()
	
func draw_line(from, to):
	radar_geo.clear()
	radar_geo.begin(Mesh.PRIMITIVE_LINES, null)
	add_vertex(from)
	add_vertex(to)
	end()

func _on_update_pos():
	if depth_cue == true:
		# from the official shader
	#	v_depth_cue = 1.0;
	#	float depth = clamp(gl_Position.z, u_min_cue_dist, u_max_cue_dist);
	#	v_depth_cue = 1.0 - clamp( (depth - u_min_cue_dist)/(u_max_cue_dist - u_min_cue_dist), 0.0, u_max_cue_level );
	
		var global_z = get_global_transform().origin.z
		var col_value = clamp(1 + global_z, 0.2, 1.2)
		
		# from official shader: they would just change the alpha
		# texColor.a *= v_depth_cue;
		set_modulate(Color(col_value,col_value,col_value,1))
	if radar_line == true:
		if assigned_battle_object != null:
			var object_pos = assigned_battle_object.position
			var zero_pos = Vector3(object_pos.x, 0, object_pos.z)
			draw_line(object_pos, zero_pos)