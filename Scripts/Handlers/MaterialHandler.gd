# class MaterialHandler
# singleton for access to globally tinted material shaders etc
# shaders and materials that are unique still have to manage themselves
extends Node

var OUTLINE = preload("res://Materials/Outline.tres")
var OUTLINE3D = preload("res://Materials/Outline3D.tres")

func set_outline(mat, texture, width, color):
	mat.set_shader_param("t", texture)
	mat.set_shader_param("outline_color", color)
	mat.set_shader_param("outline_width", width)
