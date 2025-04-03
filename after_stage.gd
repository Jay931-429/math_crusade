# after_stage.gd
extends Node2D
# UI Elements
@onready var result_label = $ResultLabel
@onready var score_label = $ScoreLabel
@onready var next_stage_button = $NextStageButton
@onready var result_image = $ResultImage
@onready var win_sprite = $ui_win  # Reference to your win sprite
@onready var lose_sprite = $ui_lose  # Reference to your lose sprite

# Variables
var player_score: int
var max_score: int
var player_won: bool
var current_stage: String
var next_stage: String

# Preload the image resources

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
	# Play appropriate music
	play_result_music()

func setup_ui() -> void:
	# Set result message
	if player_won:
		result_label.text = "You Win!"
		win_sprite.visible = true
		lose_sprite.visible = false
		next_stage_button.visible = (next_stage != "")
	else:
		result_label.text = "Game Over"
		win_sprite.visible = false
		lose_sprite.visible = true
		next_stage_button.visible = false
	# Set score display
	score_label.text = "Final Score: " + str(player_score)

func play_result_music() -> void:
	# First, add the victory and game_over tracks to the audio manager
	if not "victory" in AudioManager.music_tracks:
		AudioManager.music_tracks["victory"] = "res://asset/music/Jeremy Blake - Powerup!.mp3"
	if not "game_over" in AudioManager.music_tracks:
		AudioManager.music_tracks["game_over"] = "res://asset/music/Game Over-Sibsonic.mp3"
	
	# Play appropriate music with fade effect
	if player_won:
		AudioManager.fade_to_track("victory", 1.0)
	else:
		AudioManager.fade_to_track("game_over", 1.0)

# Button handlers
func _on_next_stage_button_pressed() -> void:
	if player_won and next_stage != "":
		get_tree().change_scene_to_file(next_stage)

func _on_replay_placeholder_pressed() -> void:
	get_tree().change_scene_to_file(current_stage)

func _on_mode_select_placeholder_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")
