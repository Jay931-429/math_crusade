extends Node2D

func _ready() -> void:
	AudioManager.change_music("menu")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_back_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")



func _on_addition_pressed() -> void:
	get_tree().change_scene_to_file("res://math_tutorial/a_tutorial.tscn")


func _on_subtraction_pressed() -> void:
	get_tree().change_scene_to_file("res://math_tutorial/s_tutorial.tscn")

func _on_multiplication_pressed() -> void:
	get_tree().change_scene_to_file("res://math_tutorial/m_tutorial.tscn")


func _on_division_pressed() -> void:
	get_tree().change_scene_to_file("res://math_tutorial/d_tutorial.tscn")


func _on_exponent_pressed() -> void:
	get_tree().change_scene_to_file("res://math_tutorial/e_tutorial.tscn")

func _on_pemdas_pressed() -> void:
	get_tree().change_scene_to_file("res://math_tutorial/p_tutorial.tscn")


func _on_gameplay_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/gameplay_tutorial.tscn")
