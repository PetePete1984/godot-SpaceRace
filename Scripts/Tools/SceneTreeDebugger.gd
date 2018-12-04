extends Node

onready var tree = get_tree()

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("debug_toggle_colliders"):
		tree.set_debug_collisions_hint(!tree.is_debugging_collisions_hint())

	if event.is_action_pressed("debug_current_scene"):
		print(tree.get_current_scene())
	pass
