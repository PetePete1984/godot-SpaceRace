extends Reference

const early_research = ["orbital_structures", "interplanetary_exploration", "tonklin_diary", "spacetime_surfing", "xenobiology"]
# industrial mega facility, metroplex, research campus, hydroponifer, hyperpower, internet, terraforming, automation, growth_bomb
const mid_research = ["positron_guidance", "large_scale_construction", "hyperlogic", "advanced_chemistry", "subatomics", "megagraph_theory", "planetary_replenishment"]

static func manage(player):
	var result = null
	if player.research_project == null:
		# no research picked
		# early game: prefer finishing everything for star travel and colonizing
		# mid game: prefer improving resource buildings
		# mid-late game: prefer terraforming if needed

		# currently open research nodes, including all in-progress but paused nodes
		var available_research = get_available_research(player)
		var early_complete = player.is_space_travel_available()
		var mid_complete = false
		if early_complete:
			# pick any
			if available_research.size() > 0:
				for m in mid_research:
					if result == null and m in available_research:
						result = m
						break
				# didn't have any preference, pick anything
				if result == null:
					result = Utils.rand_pick_from_array(available_research)
			# else probably finished with everything
			pass
		else:
			# pick early tech
			for r in early_research:
				if result == null and r in available_research:
					result = r
					break
		pass
	else:
		# research currently running
		# only repick if chamachies and special is available and it's "worth it"
		pass
	if result == null:
		pass
		#print("didn't pick research")
	else:
		print("%s picked %s" % [player.race.race_name, result])
	return result

static func get_available_research(player):
	var result = []
	for rkey in ResearchDefinitions.research_defs:
		var technology = ResearchDefinitions.research_defs[rkey]
		if player.research.has(rkey):
			if player.research[rkey].remaining_research > 0:
				result.append(rkey)
		elif not rkey in player.completed_research:
			if technology.requires.size() > 0:
				# tech has requirements, check completed research
				var available = true
				for t in technology.requires:
					available = available and t in player.completed_research
				if available:
					result.append(rkey)
			else:
				# tech has no requirements, is not being researched and not complete yet
				result.append(rkey)
	return result