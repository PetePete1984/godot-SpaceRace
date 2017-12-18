extends ImmediateGeometry

func set_system(system):
	clear()
	begin(Mesh.PRIMITIVE_LINES, null)
	# line for the star
	add_vertex(Vector3(0,3,0))
	add_vertex(Vector3(0,0,0))
	
	# draw the rest of the system's lines
	for p in system.planets:
		var planet = system.planets[p]
		add_vertex(p)
		var to = Vector3(p.x, 0, p.z)
		add_vertex(to)
	
	for s in system.ships:
		var ship = system.ships[s]
		add_vertex(s)
		var to = Vector3(s.x, 0, s.z)
		add_vertex(to)
		
	for l in system.lanes:
		var lane = system.lanes[l]
		add_vertex(l)
		var to = Vector3(l.x, 0, l.z)
		add_vertex(to)
	end()