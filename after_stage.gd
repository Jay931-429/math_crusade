# results_stage.gd
extends Node2D

# UI Elements
@onready var result_label = $ResultLabel
@onready var score_label = $ScoreLabel
@onready var next_stage_button = $NextStageButton


# Variables to store passed data
var player_score: int = 0
var max_score: int = 10
var player_won: bool = false
var current_stage: String = ""
var next_stage: String = ""
var remaining_hp: int = 0
var max_hp: int = 10

func _ready() -> void:
	# Load data from GameData
	var data = GameData.get_results_data()
	player_score = data.player_score
	max_score = data.max_score
	player_won = data.player_won
	current_stage = data.current_stage
	next_stage = data.next_stage
	remaining_hp = data.remaining_hp
	max_hp = data.max_hp

	# Setup UI based on loaded data
	setup_ui()

	# Play appropriate music based on outcome
	#if player_won:
		#AudioManager.change_music("victory")
	#else:
		#AudioManager.change_music("defeat")

func setup_ui() -> void:
	# Set result message
	if player_won:
		result_label.text = "You Win!"
		next_stage_button.visible = true
	else:
		result_label.text = "Game Over"
		next_stage_button.visible = false

	# Set score display
	score_label.text = "Final Score: " + str(player_score) + "/" + str(max_score)

# Button handlers
func _on_next_stage_button_pressed() -> void:
	# Only visible and functional if player won
	if player_won and next_stage != "":
		get_tree().change_scene_to_file("res://test_stage.tscn")


func _on_replay_placeholder_pressed() -> void:
	# Replay the current stage
	get_tree().change_scene_to_file(current_stage)


func _on_mode_select_placeholder_pressed() -> void:
	# Go back to stage selection
	get_tree().change_scene_to_file("res://mode_select.tscn")
