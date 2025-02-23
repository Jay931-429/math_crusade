# need pa ni, in fact diri ang ga manage bg music, bale no need na mag add music kada scene
# diri n lng ma insert
# tapos amoo ni ang mute sng music or ga play
extends Node

# Dictionary to store different music tracks
var music_tracks = {
	"menu": "res://asset/music/Zachz Winner, Фрози, Joyful - Boogie  Discoplug  NCS - Copyright Free Music.mp3",
	"stage": "res://asset/music/Zachz Winner - blu  Pluggnb  NCS - Copyright Free Music.mp3",
	# Add more tracks as needed
	#"game_over": "res://asset/music/game_over_music.mp3",
	#"victory": "res://asset/music/victory_music.mp3"
}

var background_music: AudioStreamPlayer
var current_track: String = ""

func _ready() -> void:
	background_music = AudioStreamPlayer.new()
	add_child(background_music)
	# Start with menu music by default
	change_music("menu")

func change_music(track_name: String) -> void:
	if track_name in music_tracks:
		# Store current playback position if we want to resume later
		var was_playing = !background_music.stream_paused
		
		# Load and play new track
		background_music.stream = load(music_tracks[track_name])
		current_track = track_name
		
		if was_playing:
			background_music.play()

func toggle_music() -> void:
	if background_music:
		background_music.stream_paused = !background_music.stream_paused

func is_playing() -> bool:
	return background_music and !background_music.stream_paused

func stop_music() -> void:
	if background_music:
		background_music.stop()

func play_from_start() -> void:
	if background_music:
		background_music.stop()
		background_music.play()

# Optional: Fade between tracks
func fade_to_track(track_name: String, fade_duration: float = 1.0) -> void:
	if track_name in music_tracks:
		# Create a new AudioStreamPlayer for the new track
		var new_player = AudioStreamPlayer.new()
		add_child(new_player)
		new_player.stream = load(music_tracks[track_name])
		new_player.volume_db = -80  # Start silent
		new_player.play()
		
		# Fade out current track
		var tween = create_tween()
		tween.tween_property(background_music, "volume_db", -80, fade_duration)
		
		# Fade in new track
		var tween2 = create_tween()
		tween2.tween_property(new_player, "volume_db", 0, fade_duration)
		
		# After fade, cleanup
		await tween.finished
		background_music.stop()
		background_music.queue_free()
		background_music = new_player
