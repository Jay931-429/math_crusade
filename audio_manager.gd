# need pa ni, in fact diri ang ga manage bg music, bale no need na mag add music kada scene
# diri n lng ma insert
# tapos amoo ni ang mute sng music or ga play


# Placed on Autoload tab
# "Global" Script (AudioManager)

extends Node

# Dictionary to store different music tracks (BGM)
var music_tracks = {
	"menu": preload("res://asset/music/Zachz Winner, Фрози, Joyful - Boogie  Discoplug  NCS - Copyright Free Music.mp3"),
	"stage1": preload("res://asset/music/The Wild New World.mp3"),
	"stage2": preload("res://asset/music/Stage 4-6 BGM MP3.mp3"),
	"stage4": preload("res://asset/music/Desert Battle.mp3"),
	"game_over": preload("res://asset/music/Game Over-Sibsonic.mp3"),
	"victory": preload("res://asset/music/Jeremy Blake - Powerup!.mp3")
	# Add more BGM tracks as needed
}

# Dictionary for Sound Effects (SFX) - Use preload!
var sfx_tracks = {
	"correct": preload("res://asset/music/resp-correct.mp3"),
	"wrong": preload("res://asset/music/donald-trump-wrong-sound-effect.mp3")
	# Add more SFX as needed (e.g., button clicks, damage sounds)
}

var background_music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer # Separate player for SFX
var current_music_track: String = ""

func _ready() -> void:
	# Create and add BGM player
	background_music_player = AudioStreamPlayer.new()
	background_music_player.name = "BackgroundMusicPlayer" # Good practice for debugging
	add_child(background_music_player)

	# Create and add SFX player
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer" # Good practice
	add_child(sfx_player)

	# Optional: Set default volumes
	# background_music_player.volume_db = 0 # 0 dB is default
	# sfx_player.volume_db = 0

	# Start with menu music by default
	change_music("menu")

# --- Music (BGM) Functions ---

func change_music(track_name: String) -> void:
	if track_name in music_tracks:
		var new_stream = music_tracks[track_name] # Get preloaded stream

		# Only change if it's a different track or not playing
		if background_music_player.stream != new_stream or not background_music_player.is_playing():
			background_music_player.stream = new_stream
			background_music_player.play()
			current_music_track = track_name
	else:
		printerr("AudioManager: Unknown music track name: ", track_name)

func toggle_music() -> void:
	if background_music_player:
		background_music_player.stream_paused = !background_music_player.stream_paused

func is_music_playing() -> bool:
	# Check is_playing() instead of stream_paused for a more accurate state
	return background_music_player and background_music_player.is_playing()

func stop_music() -> void:
	if background_music_player:
		background_music_player.stop()

# --- Sound Effect (SFX) Functions ---

# THIS IS THE FUNCTION YOUR GAME SCRIPT SHOULD CALL for correct/wrong
func play_sfx(sfx_name: String) -> void:
	if sfx_name in sfx_tracks:
		var sfx_stream = sfx_tracks[sfx_name] # Get preloaded stream
		sfx_player.stream = sfx_stream
		sfx_player.play() # Play the sound effect on its dedicated player
	else:
		printerr("AudioManager: Unknown SFX track name: ", sfx_name)

# --- Optional Fade Function (Modified) ---

# Note: Fading requires careful management if called rapidly.
# This version assumes you only fade BGM.
func fade_to_track(track_name: String, fade_duration: float = 1.0) -> void:
	if track_name in music_tracks and background_music_player:
		var new_stream = music_tracks[track_name]

		if background_music_player.stream == new_stream and background_music_player.is_playing():
			return # Already playing this track

		# Create a temporary player for the new track fade-in
		var new_player = AudioStreamPlayer.new()
		add_child(new_player)
		new_player.stream = new_stream
		new_player.volume_db = -80 # Start silent
		new_player.play()

		# Store old player reference for cleanup
		var old_player = background_music_player

		# Create tweens for fading
		var fade_out_tween = create_tween().set_parallel(false) # Sequential better here
		var fade_in_tween = create_tween().set_parallel(false)

		# Fade out current track (if playing)
		if old_player.is_playing():
			fade_out_tween.tween_property(old_player, "volume_db", -80, fade_duration)
			fade_out_tween.tween_callback(old_player.stop) # Stop after fade

		# Fade in new track
		fade_in_tween.tween_property(new_player, "volume_db", old_player.volume_db, fade_duration) # Fade to old player's volume

		# Chain tweens: fade out -> fade in -> cleanup
		await fade_out_tween.finished
		await fade_in_tween.finished

		# Cleanup: Make the new player the main player, remove old one
		background_music_player = new_player
		current_music_track = track_name
		old_player.queue_free() # Remove the old player node

	elif not (track_name in music_tracks):
		printerr("AudioManager: Unknown music track name for fade: ", track_name)
