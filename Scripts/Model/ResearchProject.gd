# current or queued research project
extends Reference

var remaining_research = 0
var initial_cost = 0
var research = ""

func progress():
	return float(remaining_research) / float(initial_cost)