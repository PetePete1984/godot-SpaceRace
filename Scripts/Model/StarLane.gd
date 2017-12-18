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