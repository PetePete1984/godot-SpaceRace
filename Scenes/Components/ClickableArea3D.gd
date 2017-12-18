extends Area

signal clicked
signal hover_begin
signal hover_end

func _input_event(camera, event, pos, normal, shape):
	if is_visible():
		if event.type==InputEvent.MOUSE_BUTTON and event.button_index == BUTTON_LEFT and event.is_pressed():
			emit_signal("clicked")

func _mouse_enter():
	emit_signal("hover_begin")
	pass

func _mouse_exit():
	emit_signal("hover_end")
	pass
