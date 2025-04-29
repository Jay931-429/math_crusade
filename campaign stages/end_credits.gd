extends Node2D

func _ready() -> void:
	AudioManager.change_music("menu")

# Called every frame
func _process(delta: float) -> void:
	pass

func _on_backbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
