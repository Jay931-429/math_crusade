# game_data.gd
# Stores players game data from a stage
# I.E score, win/lose etc.

# Placed on Autoload tab
# "Global" Script

# game_data.gd
extends Node

# Dictionary to store results data
var results_data = {
	"player_score": 0,
	"max_score": 0,
	"player_won": false,
	"current_stage": "",
	"next_stage": "",
	"remaining_hp": 0,
	"max_hp": 3
}

# Dictionary to track stage progress
var stage_progress = {
	"test_stage": {
		"unlocked": true,  # First stage is unlocked by default
		"completed": false
	},
	"test_stage_PEMDAS": {
		"unlocked": false,
		"completed": false
	},
	# Add more stages here
}

func set_results_data(data: Dictionary) -> void:
	results_data = data
	
	# Update stage progress if player won
	if data.player_won and data.current_stage != "":
		# Mark current stage as completed
		var current_stage_name = data.current_stage.get_file().get_basename()
		if stage_progress.has(current_stage_name):
			stage_progress[current_stage_name]["completed"] = true
		
		# Unlock next stage
		var next_stage_name = data.next_stage.get_file().get_basename()
		if stage_progress.has(next_stage_name):
			stage_progress[next_stage_name]["unlocked"] = true
	
	# Save progress to disk
	save_game()

func get_results_data() -> Dictionary:
	return results_data

func is_stage_unlocked(stage_name: String) -> bool:
	if stage_progress.has(stage_name):
		return stage_progress[stage_name]["unlocked"]
	return false

func is_stage_completed(stage_name: String) -> bool:
	if stage_progress.has(stage_name):
		return stage_progress[stage_name]["completed"]
	return false

# Save game progress to disk
func save_game() -> void:
	var save_data = {
		"stage_progress": stage_progress
	}
	
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(save_data)
	save_file.store_line(json_string)
	save_file.close()

# Load game progress from disk
func load_game() -> void:
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_string = save_file.get_line()
		var json_data = JSON.parse_string(json_string)
		
		if json_data is Dictionary and json_data.has("stage_progress"):
			stage_progress = json_data["stage_progress"]
		
		save_file.close()
