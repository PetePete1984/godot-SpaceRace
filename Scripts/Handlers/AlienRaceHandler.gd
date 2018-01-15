# Non-Human player Handler
extends Node

var ColonyManager = preload("res://Scripts/ColonyManager.gd")

func handle(player):
	for c in player.colonies:
		var colony = player.colonies[c]
		ColonyManager.manage(c)