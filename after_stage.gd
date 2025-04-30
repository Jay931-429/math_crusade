# after_stage.gd
extends Node2D
# UI Elements
@onready var result_label = $ResultLabel
@onready var score_label = $ScoreLabel
@onready var next_stage_button = $NextStageButton
@onready var result_image = $ResultImage
@onready var win_sprite = $ui_win  # Reference to your win sprite
@onready var lose_sprite = $ui_lose  # Reference to your lose sprite
# Star elements
@onready var star1 = $Star1  # AnimatedSprite2D for star 1
@onready var star2 = $Star2  # AnimatedSprite2D for star 2
@onready var star3 = $Star3  # AnimatedSprite2D for star 3
# Variables
var player_score: int
var max_score: int
var player_won: bool
var current_stage: String
var next_stage: String
var is_endless: bool = false  # Add at top

func _ready() -> void:
	# Load data from GameData
	var data = GameData.get_results_data()
	player_score = data.player_score
	max_score = data.max_score
	player_won = data.player_won
	current_stage = data.current_stage
	# Get next stage dynamically
	next_stage = GameData.get_next_stage(current_stage)
	is_endless = data.has("is_endless") and data.is_endless  # NEW
	# Setup UI
	setup_ui()
	# Play appropriate music
	play_result_music()
	
func setup_ui() -> void:
	# Set result message
	if is_endless:
		result_label.text = "Run Ended"
		win_sprite.visible = true
		lose_sprite.visible = false
		next_stage_button.visible = false

		star1.visible = true
		star2.visible = true
		star3.visible = true

		score_label.text = "Score: " + str(player_score)
	elif player_won:
		result_label.text = "You Win!"
		win_sprite.visible = true
		lose_sprite.visible = false
		next_stage_button.visible = (next_stage != "")
		setup_stars()
	else:
		if GameData.player_survived_but_failed:
			result_label.text = "You Survived...\nBut Didn't Pass"
		else:
			result_label.text = "Game Over"

		win_sprite.visible = false
		lose_sprite.visible = true
		next_stage_button.visible = false
		star1.visible = false
		star2.visible = false
		star3.visible = false

		score_label.text = "Final Score: " + str(player_score)

func setup_stars() -> void:
	# Calculate score percentage
	var score_percentage = float(player_score) / float(max_score)
	
	# Hide all stars initially
	star1.visible = false
	star2.visible = false
	star3.visible = false
	
	# Prepare to show stars with animation
	if score_percentage >= 0.8:  # 8/10 or better
		show_star_with_animation(star1, 0.0)
		
		
		if score_percentage >= 0.9:  # 9/10 or better
			show_star_with_animation(star2, 0.5)
			
			
			if score_percentage >= 1.0:  # 10/10 - perfect score
				show_star_with_animation(star3, 1.0)
				

func show_star_with_animation(star_sprite, delay: float) -> void:
	# Make star visible but start with zero scale
	star_sprite.visible = true
	star_sprite.scale = Vector2(0.1, 0.1)
	AudioManager.play_sfx("bling")
	
	
	# Create tween for scaling animation
	var scale_tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	
	# Add delay before animation starts if needed
	if delay > 0:
		scale_tween.tween_interval(delay)
	
	# Animate scale to original/full size
	var original_scale = Vector2(12.0, 11.0)  # Adjust if your stars have different base scale
	scale_tween.tween_property(star_sprite, "scale", original_scale, 0.5)
	
	# Start the animation sequence in the sprite
	# Wait for scaling to begin before playing animation
	await scale_tween.step_finished
	star_sprite.play("default")  # Assuming your animation is named "default"

func play_result_music() -> void:
	# First, add the victory and game_over tracks to the audio manager
	if not "victory" in AudioManager.music_tracks:
		AudioManager.music_tracks["victory"] = "res://asset/music/Jeremy Blake - Powerup!.mp3"
	if not "game_over" in AudioManager.music_tracks:
		AudioManager.music_tracks["game_over"] = "res://asset/music/Game Over-Sibsonic.mp3"
	
	# Play appropriate music with fade effect
	if player_won:
		AudioManager.fade_to_track("victory", 1.0)
	elif is_endless:
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
