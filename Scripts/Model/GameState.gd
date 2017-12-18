# Global Game State
extends Reference

# needs more options
var turn = 0
var galaxy = null
var difficulty = "easy"
var races = {}

var galaxy_settings = {
	"galaxy_size": "average",
	"atmosphere": "peaceful", # "neutral", "hostile"
	"races": 5
}

var saveable_state = {}