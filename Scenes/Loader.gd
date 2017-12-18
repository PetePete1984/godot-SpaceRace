extends Node2D

var game = preload("res://Scenes/SpaceRaceGame.tscn")
func _ready():
	get_tree().change_scene_to(game)
	pass
