extends Node2D

func _ready() -> void:
	AudioManager.change_music("menu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_back_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")



func _on_addition_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial stages/addition_tutorial.tscn")


func _on_subtraction_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial stages/subtraction_tutorial.tscn")


func _on_multiplication_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial stages/multiplication_tutorial.tscn")


func _on_division_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial stages/division_tutorial.tscn")


func _on_exponent_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial stages/exp_tutorial.tscn")


func _on_pemdas_pressed() -> void:
	get_tree().change_scene_to_file("res://tutorial stages/PEMDAS_tutorial.tscn")
