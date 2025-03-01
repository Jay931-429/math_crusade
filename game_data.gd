# game_data.gd
# Stores players game data from a stage
# I.E score, win/lose etc.

# Placed on Autoload tab
# "Global" Script

extends Node

# Dictionary to store results data
var results_data = {
	"player_score": 0,
	"max_score": 0,
	"player_won": false,
	"current_stage": "",
	"next_stage": ""
}

func set_results_data(data: Dictionary) -> void:
	results_data = data

func get_results_data() -> Dictionary:
	return results_data
