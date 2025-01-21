extends Node

# "Global" script
# The purpose is to manage the backgroud music (especially background music)

var background_music: AudioStreamPlayer

func _ready() -> void:
	background_music = AudioStreamPlayer.new()
	add_child(background_music)
	# Load your music file
	background_music.stream = preload("res://asset/music/AdhesiveWombat - Night Shade.mp3")  # Update this path
	background_music.play()

# Plays the BG music
func toggle_music() -> void:
	if background_music:
		# Instead of stop/play, we use stream_paused
		background_music.stream_paused = !background_music.stream_paused

# When pressed, it will pause the music at a specific point of the music
# When pressed again, it will continue based on the part of the music it was paused
func is_playing() -> bool:
	return background_music and !background_music.stream_paused

# Optional: If you need to stop the music completely
func stop_music() -> void:
	if background_music:
		background_music.stop()

# Optional: If you need to start from beginning
func play_from_start() -> void:
	if background_music:
		background_music.stop()
		background_music.play()
