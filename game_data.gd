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
	"remaining_hp": 0,
	"max_hp": 3
}

# Ordered list of stages (ensures proper progression)
var stage_order = [
	"res://campaign stages/addition_tutorial.tscn",
	"res://campaign stages/Stage1_3_NormalStage.tscn",
	"res://campaign stages/Stage3_boss.tscn",
	"res://campaign stages/subtraction_tutorial.tscn",
	"res://campaign stages/Stage4_6_NormalStage.tscn",
	"res://campaign stages/Stage6_boss.tscn",
	"res://campaign stages/mult_tutorial.tscn",
	"res://campaign stages/Stage7_9_NormalStage.tscn",
	"res://campaign stages/stage_9_boss.gd",
	"res://campaign stages/div_tutorial.tscn",
	"res://campaign stages/Stage10_12_NormalStage.tscn",
	"res://campaign stages/Stage12_Boss.tscn",
	"res://campaign stages/expo_tutorial.tscn",
	"res://campaign stages/Stage13_15_NormalStage.tscn",
	"res://campaign stages/Stage15_Boss.tscn",
	"res://campaign stages/PEMDAS_Tutorial1.tscn",
	"res://campaign stages/Stage16_19_NormalStage.tscn",
	"res://campaign stages/f_boss.tscn",
	"res://campaign stages/end_credits.tscn"
	# Add more stages here
]

# Dictionary to track stage progress
var stage_progress = {}

func _ready() -> void:
	# Initialize stage_progress dynamically from stage_order if not loaded
	if stage_progress.is_empty():
		for stage in stage_order:
			var stage_name = stage.get_file().get_basename()
			stage_progress[stage_name] = {
				"unlocked": stage == stage_order[0],  # Unlock the first stage only
				"completed": false
			}
	load_game()  # Load saved progress

func set_results_data(data: Dictionary) -> void:
	results_data = data

	# Update stage progress if player won
	if data.player_won and data.current_stage != "":
		var current_stage_name = data.current_stage.get_file().get_basename()
		
		# Mark current stage as completed
		if stage_progress.has(current_stage_name):
			stage_progress[current_stage_name]["completed"] = true

		# Unlock the next stage dynamically
		var next_stage = get_next_stage(data.current_stage)
		if next_stage:
			var next_stage_name = next_stage.get_file().get_basename()
			if stage_progress.has(next_stage_name):
				stage_progress[next_stage_name]["unlocked"] = true

	# Save progress to disk
	save_game()

func get_results_data() -> Dictionary:
	return results_data

func get_next_stage(current_stage: String) -> String:
	# Find the next stage in the order list
	var index = stage_order.find(current_stage)
	if index != -1 and index + 1 < stage_order.size():
		return stage_order[index + 1]  # Return the next stage file path
	return ""  # No more stages left

func is_stage_unlocked(stage_name: String) -> bool:
	return stage_progress.get(stage_name, {}).get("unlocked", false)

func is_stage_completed(stage_name: String) -> bool:
	return stage_progress.get(stage_name, {}).get("completed", false)
	

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
