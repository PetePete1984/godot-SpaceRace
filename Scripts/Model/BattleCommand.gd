enum COMMAND { NONE, MOVE, EXPLODE }

# the sprite used for animation
var actor

# the command type, see COMMAND enum
var command_type

# the target position
var target

# the target object, if required
var target_object

# normalized movement direction, to avoid recalculating every frame
var direction

# remaining travel distance
var travel_distance

func reset():
	actor = null
	command_type = COMMAND.NONE
	target = null
	target_object = null
	direction = null
	travel_distance = null