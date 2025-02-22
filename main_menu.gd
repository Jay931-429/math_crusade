extends Control



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ResponsiveLayout.adjust_game_elements()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# When pressed, the game closes
func _on_exit_pressed() -> void:
	get_tree().quit()

# toggles the music on or off
func _on_music_pressed() -> void:
	AudioManager.toggle_music()
	AudioManager.change_music("menu")

# Sends user to the info or credit page
func _on_information_pressed() -> void:
	get_tree().change_scene_to_file("res://information.tscn")

# Sends the user to mode select stage
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")
