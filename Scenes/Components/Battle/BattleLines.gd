extends ImmediateGeometry

func set_system(system):
	clear()
	begin(Mesh.PRIMITIVE_LINES, null)
	# line for the star
	add_vertex(Vector3(0,3,0))
	add_vertex(Vector3(0,0,0))
	
	# draw the rest of the system's lines
	for planet in system.planets:
		var p = planet.position
		add_vertex(p)
		var to = Vector3(p.x, 0, p.z)
		add_vertex(to)
	
	for ship in system.ships:
		var s = ship.position
		add_vertex(s)
		var to = Vector3(s.x, 0, s.z)
		add_vertex(to)
		
	for l in system.lanes:
		# TODO: needs an update if this changes to an array of lanes with positions
		var lane = system.lanes[l]
		add_vertex(l)
		var to = Vector3(l.x, 0, l.z)
		add_vertex(to)
	end()