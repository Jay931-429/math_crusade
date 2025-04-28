extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# Sends the user back to main menu
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _on_toggle_music_pressed() -> void:
	AudioManager.toggle_music()
	AudioManager.change_music("menu")


func _on_reset_button_pressed() -> void:
	PlayerData.reset_progress()
	
	# Optional: If the player is currently on the campaign map, refresh it
	# We'll send a signal or reload the map scene
	var current_scene = get_tree().current_scene
	if current_scene.name == "campaign_map_container": # Adjust if your scene name is different
		current_scene.update_stage_buttons_visuals()
