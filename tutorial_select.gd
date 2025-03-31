extends Node2D


func _on_back_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")
