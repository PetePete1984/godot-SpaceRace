extends ViewportSprite

onready var vp = get_node("../Viewport")
var offset = Vector2(0,0)
var offset_matters = false

func _ready():
	set_process_unhandled_input(true)
	offset = get_global_transform().get_origin()
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
		vp.unhandled_input(event)