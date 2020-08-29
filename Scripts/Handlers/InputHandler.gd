extends Node

signal escape
signal load_state
signal negotiation
signal manage
signal save_state

var func_map = {
	KEY_E: "escape",
	KEY_L: "load_state",
	KEY_N: "negotiation",
	KEY_M: "manage",
	KEY_S: "save_state"
}

func skip_if_escape(event):
	if event.type == InputEvent.KEY and event.scancode == KEY_ESCAPE and event.is_pressed():
		if event.unicode != 0:
			return true

func check_global_keys(event):
	# DEBUG keys
	if event.type == InputEvent.KEY and event.is_pressed():
		if event.scancode in func_map.keys():
			emit_signal(func_map[event.scancode])

		# if event.scancode == KEY_E:
		# 	pass
		# if event.scancode == KEY_S:
		# 	#GameStateHandler.save_game_state("user://debug_save.json")
		# 	pass
		# if event.scancode == KEY_L:
		# 	#GameStateHandler.load_game_state("user://debug_save.json")
		# 	pass
	pass

func feedback_mouse_click(event):
	if event.type == InputEvent.MOUSE_BUTTON and event.is_pressed():
		if not event.button_index in [4, 5, 6, 7]: # button_wheel constants
			AudioManager.bleep()