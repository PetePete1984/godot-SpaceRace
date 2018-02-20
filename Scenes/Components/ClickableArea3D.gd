extends Area

signal clicked
signal right_clicked
signal hover_begin
signal hover_end

func _input_event(camera, event, pos, normal, shape):
	if is_visible():
		if event.type==InputEvent.MOUSE_BUTTON and event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				emit_signal("clicked")
			elif event.button_index == BUTTON_RIGHT:
				emit_signal("right_clicked")

func _mouse_enter():
	emit_signal("hover_begin")
	pass

func _mouse_exit():
	emit_signal("hover_end")
	pass
