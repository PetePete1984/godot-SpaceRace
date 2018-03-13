extends "res://Scenes/Components/TileMapMouseInput.gd"

func _ready():
	# connect("tile_clicked", self, "_on_left_click")
	# connect("tile_right_clicked", self, "_on_right_click")
	# connect("tile_hover_in", self, "_on_hover_in")
	# connect("tile_hover_out", self, "_on_hover_out")
	set_process_input(true)