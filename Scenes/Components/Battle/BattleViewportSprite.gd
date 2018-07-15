extends ViewportSprite

onready var vp = get_node("../Viewport")
var offset = Vector2(0,0)
var offset_matters = false
var vp_rect

var hovering = false

signal vp_hover_end
signal vp_unspecified_click

func _ready():
	set_process_unhandled_input(true)
	offset = get_global_transform().get_origin()
	# this is used to check if input events are happening inside the viewport's dimensions
	vp_rect = vp.get_rect()
	if offset.length() > 0:
		offset_matters = true
	vp.set_render_target_update_mode(vp.RENDER_TARGET_UPDATE_ALWAYS)
	pass

func _unhandled_input(event):
	# copy the event
	# change the offset on the copy
	# pass the copy to the viewport
#	var offset = get_global_transform().get_origin()
#	if offset_matters:
#		var ev = InputEvent()
#		ev.type = event.type
#		ev.button_index = event.button_index

	# TODO: this probably distorts the event for all other handlers, keep an eye on it
	if is_visible():
		if event.type == InputEvent.MOUSE_BUTTON or event.type == InputEvent.MOUSE_MOTION:
			if offset_matters:
				event.pos -= offset
			#printt(event.type, vp_rect, event.pos)
			if vp_rect.has_point(event.pos):
				vp.set_disable_input(false)
				hovering = true
				vp.unhandled_input(event)
			else:
				if hovering:
					hovering = false
					vp.set_disable_input(true)
					emit_signal("vp_hover_end")