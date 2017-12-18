extends ImmediateGeometry

const RED = Color(1, 0, 0, 1)
const BLUE = Color(0, 0, 1, 1)
const WHITE = Color(1, 1, 1, 1)

var current_player_color = WHITE

func _ready():
	pass

func draw_lanes_for_player(galaxy, player, options = null):
	clear_lines()
	begin(Mesh.PRIMITIVE_LINES, null)
	for lane_key in galaxy.lanes:
		var lane = galaxy.lanes[lane_key]
		#print(lane_key)
		if lane.type == "blue":
			set_color(BLUE)
		else:
			set_color(WHITE)
		add_vertex(lane.galactic_positions[0])
		add_vertex(lane.galactic_positions[1])
	end()
	pass
	
func clear_lines():
	clear()
	pass