static func purge_game_state(state):
	state.turn = null
	purge_galaxy(state.galaxy)
	state.galaxy = null
	if state.races != null:
		purge_races(state.races)
		state.races = null
	#purge_human_player(state.human_player)
	state.human_player = null
	#purge_saveable_state(state.saveable_state)
	state.saveable_state = null
	state = null

static func purge_galaxy(galaxy):
	purge_systems(galaxy.systems)
	galaxy.systems = null
	purge_races(galaxy.races)
	galaxy.races = null
	purge_lanes(galaxy.lanes)
	galaxy.lanes = null
	galaxy = null

static func purge_systems(systems):
	for s in systems:
		var system = systems[s]

		purge_planets(system.planets)
		system.planets = null
		system.lanes = null
		system.ships = null
		system.nebulae = null
		system.pivot = null

		system = null
		systems[s] = null
	systems = null

static func purge_lanes(lanes):
	for l in lanes:
		var lane = lanes[l]

		lane.connects = null
		lane.galactic_positions = null
		lane.positions = null
		lane.directions = null

		lane = null
		lanes[l] = null
	lanes = null

static func purge_races(races):
	for r in races:
		var player = races[r]
		
		if player != null:
			player.race = null
			purge_colonies(player.colonies)
			player.colonies = null
			purge_ships(player.ships)
			player.ships = null
			purge_research(player.research)
			player.research = null
			player.completed_research = null
			player.research_project = null
			player.color = null
			if player.knowledge:
				purge_knowledge(player.knowledge)
				player.knowledge = null

		player = null
		races[r] = null
	races = null

static func purge_colonies(colonies):
	for c in colonies:
		var colony = colonies[c]

		colony.project = null
		colony.owner = null
		colony.planet = null

		colony = null
		colonies[c] = null
	colonies = null

static func purge_ships(ships):
	for s in ships:
		var ship = ships[s]

		ship = null
		ships[s] = null
	ships = null

static func purge_research(research):
	for r in research:
		research[r] = null
	research = null

static func purge_knowledge(knowledge):
	knowledge.systems = null
	knowledge.lanes = null
	knowledge.races = null
	knowledge = null

static func purge_planets(planets):
	for p in planets:
		var planet = planets[p]

		planet.owner = null
		planet.colony = null
		planet.system = null
		purge_grid(planet.grid)
		planet.grid = null
		purge_buildings(planet.buildings)
		planet.buildings = null
		purge_orbitals(planet.orbitals)
		planet.orbitals = null

		planet = null
		planets[p] = null
	planets = null

static func purge_grid(grid):
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			var tile = grid[x][y]
			tile.tiletype = null
			tile = null
			grid[x][y] = null
		grid[x] = null
	grid = null

static func purge_buildings(grid):
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			var tile = grid[x][y]
			tile.type = null
			tile = null
			grid[x][y] = null
		grid[x] = null
	grid = null

static func purge_orbitals(grid):
	for x in range(grid.size()):
		for y in range(grid[x].size()):
			var tile = grid[x][y]
			tile.type = null
			tile = null
			grid[x][y] = null
		grid[x] = null
	grid = null 