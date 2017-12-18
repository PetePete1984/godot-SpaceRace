var race = null

var type = "human" # "ai"

var extinct = false

var colonies = {}
var ships = {}

var research = {}
var completed_research = []

var research_project = null
var buffered_research = 0
var total_research = 0

# initialized from mapdefs colors
var color = null

var stats = {
	starlane_factor = 1
}

var knowledge = null

# TODO: reset project on new game
func start_research(project):
	research_project = project
	research[project.research] = project

func finish_research_project():
	var project = research_project.research
	completed_research.append(project)
	research[project].remaining_research = 0
	pass
	
func get_total_research():
	var sum = 0
	for c in colonies:
		var colony = colonies[c]
		sum += colony.adjusted_research
	return sum