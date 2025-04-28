extends Node2D




func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func _on_backbutton_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial_select.tscn")
