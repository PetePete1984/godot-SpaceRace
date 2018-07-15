enum COMMAND { NONE, MOVE, EXPLODE }

# the sprite used for animation
var actor

# the command type, see COMMAND enum
var command_type

# the target position
var target

# the target object, if required
var target_object

func reset():
	actor = null
	command_type = COMMAND.NONE
	target = null
	target_object = null