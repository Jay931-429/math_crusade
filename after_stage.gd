# after_stage.gd
extends Node2D

# UI Elements
@onready var result_label = $ResultLabel
@onready var score_label = $ScoreLabel
@onready var next_stage_button = $NextStageButton

# Variables
var player_score: int
var max_score: int
var player_won: bool
var current_stage: String
var next_stage: String

func _ready() -> void:
	# Load data from GameData
	var data = GameData.get_results_data()
	player_score = data.player_score
	max_score = data.max_score
	player_won = data.player_won
	current_stage = data.current_stage

	# Get next stage dynamically
	next_stage = GameData.get_next_stage(current_stage)

	# Setup UI
	setup_ui()

func setup_ui() -> void:
	# Set result message
	if player_won:
		result_label.text = "You Win!"
		next_stage_button.visible = (next_stage != "")  # Hide if no next stage
	else:
		result_label.text = "Game Over"
		next_stage_button.visible = false

	# Set score display
	score_label.text = "Final Score: " + str(player_score) + "/" + str(max_score)

# Button handlers
func _on_next_stage_button_pressed() -> void:
	if player_won and next_stage != "":
		get_tree().change_scene_to_file(next_stage)

func _on_replay_placeholder_pressed() -> void:
	get_tree().change_scene_to_file(current_stage)

func _on_mode_select_placeholder_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")
