# BuildingRules
extends Node

func get_projects_for_surface(planet, cell, building_tile):
	var player = planet.owner
	var cell_grid = planet.grid
	var building_grid = planet.buildings
	
	var projects = []
	var existing_building_type = null
	# TODO: include planet projects like party, scientific takeover etc
	# TODO: colony base can be automated
	# TODO: transport tubes can apparently be built everywhere
	var tiletype = cell.tiletype
	
	if building_tile.type != null:
		existing_building_type = building_tile.type.type
	
	for bdef_key in BuildingDefinitions.building_defs:
		# TODO: apply restrictions imposed by research progress
		# this is the building that wants to be built
		var building = BuildingDefinitions.building_defs[bdef_key]
		
		# collect all variables that define if this building is buildable on this tile by this player
		var allowed = true
		
		# check for research
		if building.requires_research != null:
			if player != null:
				if not building.requires_research in player.completed_research:
					continue

		# short-circuit if it's not buildable
		if not building.buildable:
			continue

		# there are two concepts at play here that are similar but not equal
		# 1: there is no building on a tile
		# 2: there is a building on a tile
		# 2: if there is a building on a tile, there are restrictions depending on:
		#  - what you're trying to build
		#  - what's already there
		
		if existing_building_type == null:
			# no building on the tile
			# if there are building requirements for the bdef_key we're looking at, it can't be placed on empty
			# don't even bother with the tile below it
			if building.replaces != null:
				continue
			#if BuildingDefinitions.building_restriction.has(bdef_key):
			#	continue

			# the color of the tile decides what can be built
			# special rule: orfa can build everything on black
			# special rule 2: nobody can build tubes or terraforming on normal squares
			# if there are any restrictions defined for this tile color (and there should be)
			if BuildingDefinitions.cell_restriction.has(tiletype):
				# get the restrictions
				var cell_restr = BuildingDefinitions.cell_restriction[tiletype]
				# this cell only allows certain buildings
				if cell_restr.has("allowed"):
					# TODO: orfa can build everything on black
					if not bdef_key in cell_restr["allowed"]:
						allowed = false
				# this cell excludes certain buildings
				elif cell_restr.has("restricted"):
					if bdef_key in cell_restr["restricted"]:
						allowed = false
			pass
		else:
			# there is a building on the tile
			# if the building is replaceable, unlike the colony base for example
			# there are restrictions as to what it can be replaced with
			# the very special case here are xeno ruins, which can only take a xeno dig, and only if they're next to a built tile already
			# the "normal" special cases are tubes, which can be replaced by terraforming (that deletes the tubes!)
			# ergo, if the building is replaceable, then the color underneath dictates by what
			var existing_building = BuildingDefinitions.building_defs[existing_building_type]

			if not existing_building.replaceable:
				allowed = false
			else:
				# if the building def we're looking at has a building restriction
				# it can only be placed on specific buildings
				if building.replaces != null:
					for rep in building.replaces:
						if allowed:
							allowed = allowed and rep == existing_building_type
						else:
							break
				
				if existing_building.replaced_by != null:
					for rep in existing_building.replaced_by:
						if allowed:
							allowed = allowed and rep == bdef_key
						else:
							break

				if allowed:
					# special case in which xeno ruins can only be used if directly connected to the rest of the base
					if existing_building_type == "xeno_ruins":
						var x = building_tile.tilemap_x
						var y = building_tile.tilemap_y

						# get the tiles around the one that was clicked
						var surrounding_tiles = Utils.get_tile_neighbors(x, y, building_grid)
						var can_build = false
						for t in surrounding_tiles:
							# surrounding_tiles[t] is supposed to be a building type
							if surrounding_tiles[t] != null:
								if not can_build and surrounding_tiles[t].type != null:
									can_build = true
							
						if not can_build:
							allowed = false
					else:
						# otherwise, the tile under the building decides what's okay
						# if there are any restrictions defined for this tile color (and there should be)
						if BuildingDefinitions.cell_restriction.has(tiletype):
							# get the restrictions
							var cell_restr = BuildingDefinitions.cell_restriction[tiletype]
							# this cell only allows certain buildings
							if cell_restr.has("allowed"):
								# TODO: orfa can build everything on black
								if not bdef_key in cell_restr["allowed"]:
									allowed = false
							# this cell excludes certain buildings
							elif cell_restr.has("restricted"):
								if bdef_key in cell_restr["restricted"]:
									allowed = false
		
		if allowed:
			projects.append(bdef_key)
	# TODO: sort by cell preference or whatever
	return projects

