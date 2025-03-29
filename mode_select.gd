extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.change_music("menu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# When Presed, the user returns to main menu
func _on_back_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

# When pressed, the user is sent to the opening scene or the opening stage of the game
# For now,it just lead to a test stage.
func _on_campaign_pressed() -> void:
	get_tree().change_scene_to_file("res://Stage1_3_NormalStage.tscn")


func _on_stages_pressed() -> void:
	get_tree().change_scene_to_file("res://map_stage.tscn")
