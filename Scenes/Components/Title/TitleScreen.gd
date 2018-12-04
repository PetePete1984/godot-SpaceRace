extends "res://Scripts/Model/Screen.gd"

signal new_game
signal resume_game

func _ready():
	get_node("VBoxContainer/Panel2/Button").connect("pressed", self, "_on_new_game")
	get_node("VBoxContainer/Panel3/Return").connect("pressed", self, "_on_resume_game")
	pass

func set_payload(payload):
	pass

func _on_new_game():
	emit_signal("new_game")
	
func _on_resume_game():
	emit_signal("resume_game")