# PlayerData.gd
extends Node

# Path to save the player's progress
const SAVE_PATH = "user://player_progress.sav"
const ENDLESS_SAVE_PATH = "user://endless_high_score.sav"
const UNLOCK_SAVE_PATH = "user://unlock_data.sav"

# Variable to store the highest stage the player has unlocked.
# Starts at 1, meaning Stage 1 is unlocked by default.
var highest_stage_unlocked: int = 1

var endless_high_score: int = 0
var endless_mode_unlocked: bool = false

func _ready():
	# Load progress when the game starts
	load_progress()
	load_endless_score()
	load_unlock_state()

# Call this function from your stage scene when the player successfully completes it
func complete_stage(stage_number: int):
	# Only increment if the completed stage is the current highest unlocked one
	if stage_number == highest_stage_unlocked:
		highest_stage_unlocked += 1
		save_progress()
		print("Unlocked stage: ", highest_stage_unlocked) # Optional: for debugging
		# Unlock Endless Mode if Stage 19 is completed
		
	if stage_number >= 19:
		endless_mode_unlocked = true
		save_unlock_state()

func save_progress():
	# Use FileAccess to save the variable
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(highest_stage_unlocked)
		# Note: FileAccess.close() is called automatically when 'file' goes out of scope
		print("Progress saved. Highest unlocked: ", highest_stage_unlocked)
	else:
		printerr("Error saving progress: ", FileAccess.get_open_error())


func load_progress():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		if file:
			# Read the variable back
			var loaded_data = file.get_var()
			# Basic type check
			if typeof(loaded_data) == TYPE_INT:
				highest_stage_unlocked = loaded_data
				print("Progress loaded. Highest unlocked: ", highest_stage_unlocked)
			else:
				printerr("Error loading progress: Invalid data type found.")
				# Optionally reset to default if data is corrupt
				highest_stage_unlocked = 1
				save_progress() # Save the default value
		else:
			printerr("Error loading progress: ", FileAccess.get_open_error())
			# Could fall back to default here too
			highest_stage_unlocked = 1
	else:
		print("No save file found. Starting new game progress.")
		# Ensure default value if no save file exists
		highest_stage_unlocked = 1
		# Optionally save the initial state immediately
		# save_progress()

# Optional: Function to reset progress for testing
func reset_progress():
	highest_stage_unlocked = 1
	save_progress()
	print("Progress reset.")
	
	
func save_endless_score(score: int) -> void:
	if score > endless_high_score:
		endless_high_score = score
		var file = FileAccess.open(ENDLESS_SAVE_PATH, FileAccess.WRITE)
		if file:
			file.store_var(endless_high_score)
			print("New endless high score saved: ", endless_high_score)

func load_endless_score() -> void:
	if FileAccess.file_exists(ENDLESS_SAVE_PATH):
		var file = FileAccess.open(ENDLESS_SAVE_PATH, FileAccess.READ)
		if file:
			endless_high_score = file.get_var()
			print("Loaded endless high score: ", endless_high_score)
	else:
		endless_high_score = 0

func save_unlock_state():
	var file = FileAccess.open(UNLOCK_SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(endless_mode_unlocked)

func load_unlock_state():
	if FileAccess.file_exists(UNLOCK_SAVE_PATH):
		var file = FileAccess.open(UNLOCK_SAVE_PATH, FileAccess.READ)
		if file:
			endless_mode_unlocked = file.get_var()
	else:
		endless_mode_unlocked = false
