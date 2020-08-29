# class MaterialHandler
# singleton for access to globally tinted material shaders etc
# shaders and materials that are unique still have to manage themselves
extends Node

var OUTLINE = preload("res://Materials/Outline.tres")
var OUTLINE3D = preload("res://Materials/Outline3D.tres")

# used for text and other default white things
var TINT = preload("res://Materials/Tint.tres")
# used for non-BW flag images, I think
var TINT_FROM_GREEN = preload("res://Materials/TintFromGreen.tres")

var tintImageMaterial
var tintImageFromGreenMaterial
var textMaterial

var playerTintMaterials = {}

func _ready():
	# TODO: set up material for "fresh" "return to game" galaxy
	for col_key in mapdefs.galaxy_colors.keys():
		var mat_slot = TINT.duplicate()
		mat_slot.set_shader_param("Color", mapdefs.galaxy_colors[col_key])
		playerTintMaterials[col_key] = mat_slot
	print(playerTintMaterials)

# TODO: needs a func to set up materials after reloading
# TODO: needs a func to set up the current player's color, even after switching players

func set_outline(mat, texture, width, color):
	mat.set_shader_param("t", texture)
	mat.set_shader_param("outline_color", color)
	mat.set_shader_param("outline_width", width)

# TODO: use this where materials are assigned
func get_player_material(player):
	return playerTintMaterials[player.color_key]
