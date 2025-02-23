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

# Sends user to the info or credit page

# Sends the user to mode select stage
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")

# When Pressed, sends user to information (now credits) scene to allow the
# users to view the credits
func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://information.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Settings.tscn")
