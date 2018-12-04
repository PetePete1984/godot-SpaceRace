# Any Game Screen
extends Node2D

export var _is_overlay = false
var trigger_update = false
var payload

func set_payload(payload):
	pass
	
func is_overlay():
	return _is_overlay