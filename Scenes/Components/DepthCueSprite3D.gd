# Sprite3D that darkens when moved globally
# TODO: Depth cueing could probably be done in a shader
extends Sprite3D

export var depth_cue = true

func _ready():
	_on_update_pos()

func _on_update_pos():
	if depth_cue:
		# taken from the official shader
	#	v_depth_cue = 1.0;
	#	float depth = clamp(gl_Position.z, u_min_cue_dist, u_max_cue_dist);
	#	v_depth_cue = 1.0 - clamp( (depth - u_min_cue_dist)/(u_max_cue_dist - u_min_cue_dist), 0.0, u_max_cue_level );
	
		var global_z = get_global_transform().origin.z
		var col_value = clamp(1 + global_z, 0.2, 1.2)
		
		# from official shader: they would just change the alpha
		# texColor.a *= v_depth_cue;
		set_modulate(Color(col_value,col_value,col_value,1))