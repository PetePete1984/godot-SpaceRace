# class StarLane.gd
extends Reference

var type = "blue" # red, blue
# calculate once, store forever
var length = 0

# TODO: this smells like a subclass
# two System identifiers to store which systems are connected
var connects = []
# the global vectors connected by this lane
var galactic_positions = []
# the in-system position of the exits
var positions = []
var directions = []

# [System]: {galactic_position: v3, position: v3, direction: v3}
var connections = {}

var exits = []

func from_to(from):
	return connects[connects.find(from) + 1 % connects.size()]