# class PlayerKnowledge
# stores information about systems, ships and starlanes that are known to this player
# can be enriched by special abilities or diplomatic actions
extends Reference

class Visibility:
	var object
	var visible = false
	
# star systems
var systems = {}
# star lanes
var lanes = {}
# races in general
var races = {}