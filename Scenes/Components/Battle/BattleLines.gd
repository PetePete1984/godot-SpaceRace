extends ImmediateGeometry

class SysLine3D:
	var from
	var to

	func _init(f, t):
		from = f
		to = t

var lines = []

func set_system(system):
	var num_objects = 1 + system.planets.size() + system.ships.size() + system.lanes.size()
	lines.resize(num_objects)
	# TODO: use a global vector3 for star positions, those never change
	var index = 0
	var star_line = SysLine3D.new(Vector3(0,3,0), Vector3(0,0,0))

	lines[index] = star_line
	index += 1
	
	# find the rest of the system's lines
	for planet in system.planets:
		var p = planet.position
		var to = Vector3(p.x, 0, p.z)
		lines[index] = SysLine3D.new(p, to)
		index += 1
	
	for ship in system.ships:
		var s = ship.position
		var to = Vector3(s.x, 0, s.z)
		lines[index] = SysLine3D.new(s, to)
		index += 1
		
	for l in system.lanes:
		# TODO: needs an update if this changes to an array of lanes with positions
		var lane = system.lanes[l]
		var to = Vector3(l.x, 0, l.z)
		lines[index] = SysLine3D.new(l, to)
		index += 1
	
	draw_lines()

func draw_lines():
	clear()
	begin(Mesh.PRIMITIVE_LINES, null)
	for line in lines:
		add_vertex(line.from)
		add_vertex(line.to)
	end()
