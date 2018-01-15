extends Node2D

onready var galaxy_root = get_node("Viewport/galaxy_root")

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	pass

func repaint(game_state):
	var interaction = false
	galaxy_root.set_galaxy(game_state, interaction)
	pass
	
func _process(delta):
	galaxy_root.rotate(delta, 1)