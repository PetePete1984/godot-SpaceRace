extends Reference
# Planet Map responsible for creating and refreshing the correct tilemap for a planet

const TILE_WIDTH = 68
const TILE_HEIGHT = 34
const BUILDABLE_OFFSET = 5

const Planet = preload("res://Scripts/Model/Planet.gd")
const PlanetGenerator = preload("res://Scripts/PlanetGenerator.gd")

static func refresh_grids(planet):
	var cells = mapdefs.cell_types
	var buildings = BuildingDefinitions.building_types
	
	if planet.grid.size() != planet.buildings.size():
		print("Grid size doesn't match building grid size")
	
	# FIXME: this should happen on init, before the planet is viewed, otherwise it'll never work
	# reset buildable state
	for x in range(planet.grid.size()):
		for y in range(planet.grid[x].size()):
			planet.grid[x][y].buildable = false

	# buildings first
	# FIXME: keep an eye on black squares next to colony bases, might be broken
	# FIXME: keep an eye on empty tiles next to xeno ruins, might also be broken
	for x in range(planet.grid.size()):
		for y in range(planet.grid[x].size()):
			var building = planet.buildings[x][y]
			if building.type != null:
				var building_type = building.type.type
				var building_index = buildings.find(building_type)
				
				if building_index != -1:
					if building.active:
						if building_type != "xeno_ruins":
							var neighbors = Utils.get_tile_neighbors(x, y, planet.grid)
							for n in neighbors:
								if neighbors[n] != null:
									if neighbors[n].tiletype != null:
										neighbors[n].buildable = true
						#tilemap_buildings.set_cell(x, y, building_index)
	
	# tiles second
	for x in range(planet.grid.size()):
		for y in range(planet.grid[x].size()):
			var tile = planet.grid[x][y]
			var cell_index = cells.find(tile.tiletype)
			
			if cell_index != -1:
				if tile.buildable == false:
					cell_index += BUILDABLE_OFFSET
				#tilemap_cells.set_cell(x, y, cell_index)
			else:
				#print("found weird tile")
				pass
	pass


static func get_tilemap_from_planet(planet, tilemap_cells, tilemap_buildings, tilemap_orbitals):
	tilemap_cells.clear()
	tilemap_buildings.clear()
	#tilemap_orbitals.clear()
	
	var cells = mapdefs.cell_types
	var buildings = BuildingDefinitions.building_types
	var orbital_tiles = OrbitalDefinitions.orbital_types
	
	# buildings first
	# FIXME: keep an eye on black squares next to colony bases, might be broken
	# FIXME: keep an eye on empty tiles next to xeno ruins, might also be broken
	for x in range(planet.grid.size()):
		for y in range(planet.grid[x].size()):
			var building = planet.buildings[x][y]
			if building.type != null:
				var building_type = building.type.type
				var building_index = buildings.find(building_type)
				
				if building_index != -1:
					if building.active:
						tilemap_buildings.set_cell(x, y, building_index)
	
	# tiles second
	for x in range(planet.grid.size()):
		for y in range(planet.grid[x].size()):
			var tile = planet.grid[x][y]
			var cell_index = cells.find(tile.tiletype)
			
			if cell_index != -1:
				if tile.buildable == false:
					cell_index += BUILDABLE_OFFSET
				tilemap_cells.set_cell(x, y, cell_index)
	
	# orbitals last, they don't influence the other buildings
	for x in range(planet.orbitals.size()):
		for y in range(planet.orbitals[x].size()):
			var orbital = planet.orbitals[x][y]
			if orbital.type != null:
				var orbital_index = orbital_tiles.find(orbital.type.type)

				if orbital_index != -1:
					if orbital.active:
						tilemap_orbitals.set_cell(x, y, orbital_index)
				
	
static func count_cells(planet):
	var cells = mapdefs.cell_types
	var cellcount = {"all": 0, "usable": 0}
	for c in range(cells.size()):
		cellcount[cells[c]] = 0
	
	for x in range(planet.grid.size()):
		for y in range(planet.grid[x].size()):
			var tile = planet.grid[x][y]
			var tile_type = tile.tiletype
			if tile_type != null:
				cellcount["all"] += 1
				cellcount[tile_type] += 1
				# TODO: orfa can use all squares
				if tile_type != "black":
					cellcount["usable"] += 1
		
	return cellcount
	pass
	
static func generate_planet():
	#randomize()
	return PlanetGenerator.generate_planet()