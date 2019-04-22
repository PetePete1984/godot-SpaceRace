var current_state
var default_state = "idle"
var state_stack = []

var states_map = {

}

var blackboard = {}

signal move(mover, movement)
signal move_to(mover, position)
signal arrive(mover, target)

func change_state_immediate(state):
	pass

func change_state(state):
	if current_state != null:
		current_state.exit()
		if current_state in state_stack:
			state_stack.erase(current_state)

	state_stack.push_front(state)
	current_state = state
	current_state.enter(blackboard)

func process(delta):
	if current_state != null:
		current_state.process(delta)

func _on_any_click(event, coords, rotation):
	if current_state != null:
		current_state.space_clicked(event, coords, rotation)

func _on_battle_object_picked(object):
	if current_state != null:
		current_state.click_object(object)

func _on_battle_object_hover_begin(object):
	if current_state != null:
		current_state.hover_object_begin(object)

func _on_battle_object_hover_end(object):
	if current_state != null:
		current_state.hover_object_end(object)