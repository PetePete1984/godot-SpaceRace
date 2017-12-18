extends ImmediateGeometry

export var lines = 28
export var line_dist = 3

func _ready():
	begin(Mesh.PRIMITIVE_LINES)
	for x in range(lines):
		var offset_x = x-14
		var xpos = offset_x * line_dist
		var zpos = (lines * line_dist) / 2
		var from = Vector3(xpos, 0, -zpos)
		var to = Vector3(xpos, 0, zpos)
		add_vertex(from)
		add_vertex(to)
		
	for z in range(lines):
		var offset_z = z-14
		var xpos = (lines * line_dist) / 2
		var zpos = offset_z * line_dist
		var from = Vector3(-xpos, 0, zpos)
		var to = Vector3(xpos, 0, zpos)
		add_vertex(from)
		add_vertex(to)
	end()
	pass
