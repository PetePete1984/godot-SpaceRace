extends Camera

onready var target = get_node("../battle_center")

func _ready():
	# TODO: look at center of galaxy (star) or stored position
	var view_target = target.get_translation() + Vector3(0,3,0)
	#look_at(view_target, Vector3(0,1,0))
	pass
