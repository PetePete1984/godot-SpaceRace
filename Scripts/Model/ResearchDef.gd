extends Reference

# definition of a researchable technology

var type = ""
var research_name = ""
var position = Vector3(0,0,0)
# TODO: this will be a pretty ugly workaround
var position_set = false

var cost = 0
# maybe
var index = 0
var requires = []

var allows = {
	"surface": [],
	"orbital": [],
	"tech": [],
	"ship_module": []
}