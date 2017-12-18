extends Camera

onready var target = get_node("../battle_center")

func _ready():
	look_at(target.get_translation(), Vector3(0,1,0))
	pass
