extends Node2D

@export var drag_speed: float = 1.0 # Adjust for scrolling sensitivity

var dragging: bool = false
var drag_start_position: Vector2
var min_drag_x: float
var max_drag_x: float

@onready var map_sprite: Sprite2D = $Map # Assuming your map Sprite2D is named "Map"

func _ready():
	# Calculate the draggable boundaries
	var map_width = map_sprite.get_rect().size.x * map_sprite.scale.x
	var screen_width = get_viewport_rect().size.x

	min_drag_x = screen_width - map_width
	max_drag_x = 0.0

	# Start the map at the beginning of the campaign
	position.x = max_drag_x

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start_position = event.position
			else:
				dragging = false
	elif event is InputEventMouseMotion:
		if dragging:
			var drag_delta = event.position - drag_start_position
			position.x = clamp(position.x + drag_delta.x * drag_speed, min_drag_x, max_drag_x)
			drag_start_position = event.position

	# For touch input (optional)
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			if event.index == 0: # First touch
				dragging = true
				drag_start_position = event.position
		elif event.is_released():
			if event.index == 0:
				dragging = false
		elif event.is_moved():
			if dragging and event.index == 0:
				var drag_delta = event.position - drag_start_position
				position.x = clamp(position.x + drag_delta.x * drag_speed, min_drag_x, max_drag_x)
				drag_start_position = event.position

# Function to load a stage when a button is pressed
#func _on_stage_button_pressed(stage_id):
	#print("Loading stage:", stage_id)
	# Replace this with your actual scene loading logic
	# get_tree().change_scene_to_file("res://stages/stage_" + str(stage_id) + ".tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")


func _on_s_1_pressed() -> void:
		get_tree().change_scene_to_file("res://campaign stages/addition_tutorial.tscn")


func _on_s_2_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage1_3_NormalStage.tscn")


func _on_s_3_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage3_boss.tscn")


func _on_s_4_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/subtraction_tutorial.tscn")


func _on_s_5_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage4_6_NormalStage.tscn")


func _on_s_6_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage6_boss.tscn")


func _on_s_7_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/mult_tutorial.tscn")


func _on_s_8_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage7_9_NormalStage.tscn")


func _on_s_9_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage9_Boss.tscn")


func _on_s_10_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/div_tutorial.tscn")


func _on_s_11_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage10_12_NormalStage.tscn")


func _on_s_12_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage12_Boss.tscn")


func _on_s_13_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/expo_tutorial.tscn")


func _on_s_14_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage13_15_NormalStage.tscn")


func _on_s_15_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage15_Boss.tscn")


func _on_s_16_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/PEMDAS_Tutorial1.tscn")


func _on_s_17_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage16_19_NormalStage.tscn")


func _on_s_18_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/Stage18_Preboss.tscn")


func _on_s_19_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/f_boss.tscn")
