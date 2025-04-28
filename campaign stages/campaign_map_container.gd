extends Node2D

@export var drag_speed: float = 1.0

var dragging: bool = false
var drag_start_position: Vector2
var min_drag_x: float
var max_drag_x: float

@onready var map_sprite: Sprite2D = $Map
# --- Add references to ALL your stage buttons ---
# It's highly recommended to group your stage buttons under a parent node
# in the scene tree (e.g., a Node named "StageButtons") for organization.
# Adjust the paths ($StageButtons/S_1, etc.) if your structure is different.
@onready var stage_buttons: Array[Button] = [
	$Map/s1, $Map/s2, $Map/s3, $Map/s4,
	$Map/s5, $Map/s6, $Map/s7, $Map/s8,
	$Map/s9, $Map/s10, $Map/s11, $Map/s12,
	$Map/s13, $Map/s14, $Map/s15, $Map/s16,
	$Map/s17, $Map/s18, $Map/s19
]
# --- Optional: Add references to Lock Icons if you have them ---
# Assuming you have Sprite2D nodes named S_1_Lock, S_2_Lock etc. as children
# of the respective buttons or positioned nearby.
# @onready var lock_icons: Array[Node2D] = [
#     $StageButtons/S_1/S_1_Lock, $StageButtons/S_2/S_2_Lock, #... and so on
# ]


func _ready():
	# Calculate draggable boundaries
	var map_width = map_sprite.get_rect().size.x * map_sprite.scale.x
	var screen_width = get_viewport_rect().size.x

	# Ensure map_width is not smaller than screen_width to avoid issues
	if map_width > screen_width:
		min_drag_x = screen_width - map_width
		max_drag_x = 0.0
	else:
		# If map is smaller than screen, don't allow dragging
		min_drag_x = 0.0
		max_drag_x = 0.0

	# Start the map at the beginning
	position.x = max_drag_x

	# --- Update buttons based on loaded progress ---
	update_stage_buttons_visuals()


func update_stage_buttons_visuals():
	# Access the global player data
	var unlocked_level = PlayerData.highest_stage_unlocked # Make sure PlayerData Autoload exists

	# Ensure stage_buttons array is populated correctly in _ready or via @onready
	if stage_buttons.is_empty():
		printerr("Stage buttons array is empty!")
		return # Exit if buttons aren't ready

	for i in range(stage_buttons.size()):
		var button = stage_buttons[i]
		# Check if the button node actually exists before accessing it
		if not is_instance_valid(button):
			printerr("Invalid button instance at index: ", i)
			continue # Skip to the next iteration

		var stage_num = i + 1 # Array index is 0-based, stages are 1-based

		if stage_num <= unlocked_level:
			# --- Stage is UNLOCKED ---
			# Make sure it's visible and enabled
			button.visible = true
			button.disabled = false
			# Optional: Hide any associated lock icon if you had one
			# Example: if lock_icons.size() > i and is_instance_valid(lock_icons[i]): lock_icons[i].visible = false
		else:
			# --- Stage is LOCKED ---
			# Make the button invisible
			button.visible = false
			# No need to disable it if it's invisible, but doesn't hurt either
			# button.disabled = true # Optional, but redundant if invisible
			# Optional: Ensure any associated lock icon is also hidden (as the button is hidden)
			# Example: if lock_icons.size() > i and is_instance_valid(lock_icons[i]): lock_icons[i].visible = false

# --- (Rest of your campaign map script: _on_back_pressed, _on_s_X_pressed, etc.) ---


func _input(event):
	# --- Input handling code remains the same ---
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start_position = get_global_mouse_position() # Use global for consistency
			else:
				dragging = false
	elif event is InputEventMouseMotion:
		if dragging:
			var current_mouse_pos = get_global_mouse_position()
			var drag_delta = current_mouse_pos - drag_start_position
			# Only apply horizontal drag
			position.x = clamp(position.x + drag_delta.x * drag_speed, min_drag_x, max_drag_x)
			drag_start_position = current_mouse_pos

	# Touch input handling remains the same (consider using global positions here too)
	elif event is InputEventScreenTouch:
		if event.index == 0: # Process only the first touch for dragging
			if event.is_pressed():
				dragging = true
				drag_start_position = event.position # Use local position for touch delta calculation
			elif event.is_released():
				dragging = false
	elif event is InputEventScreenDrag and event.index == 0: # Use ScreenDrag for touch motion
		if dragging:
			# Relative drag is simpler for touch
			position.x = clamp(position.x + event.relative.x * drag_speed, min_drag_x, max_drag_x)


# --- Back Button ---
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")

# --- Stage Button Presses (Modified) ---
# Now we check if the stage is unlocked before changing scene.

func _on_s_1_pressed() -> void:
	if 1 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/addition_tutorial.tscn")
	else:
		print("Stage 1 is locked!") # Should technically not happen if default is 1

func _on_s_2_pressed() -> void:
	if 2 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage1_3_NormalStage.tscn")
	else:
		print("Stage 2 is locked!")
		# Optional: Play a 'locked' sound effect

func _on_s_3_pressed() -> void:
	if 3 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage3_boss.tscn")
	else:
		print("Stage 3 is locked!")

func _on_s_4_pressed() -> void:
	if 4 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/subtraction_tutorial.tscn")
	else:
		print("Stage 4 is locked!")

# ... Repeat this pattern for ALL stage buttons (S_5 to S_19) ...

func _on_s_5_pressed() -> void:
	if 5 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage4_6_NormalStage.tscn")
	else: print("Stage 5 is locked!")

func _on_s_6_pressed() -> void:
	if 6 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage6_boss.tscn")
	else: print("Stage 6 is locked!")

func _on_s_7_pressed() -> void:
	if 7 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/mult_tutorial.tscn")
	else: print("Stage 7 is locked!")

func _on_s_8_pressed() -> void:
	if 8 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage7_9_NormalStage.tscn")
	else: print("Stage 8 is locked!")

func _on_s_9_pressed() -> void:
	if 9 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage9_Boss.tscn")
	else: print("Stage 9 is locked!")

func _on_s_10_pressed() -> void:
	if 10 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/div_tutorial.tscn")
	else: print("Stage 10 is locked!")

func _on_s_11_pressed() -> void:
	if 11 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage10_12_NormalStage.tscn")
	else: print("Stage 11 is locked!")

func _on_s_12_pressed() -> void:
	if 12 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage12_Boss.tscn")
	else: print("Stage 12 is locked!")

func _on_s_13_pressed() -> void:
	if 13 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/expo_tutorial.tscn")
	else: print("Stage 13 is locked!")

func _on_s_14_pressed() -> void:
	if 14 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage13_15_NormalStage.tscn")
	else: print("Stage 14 is locked!")

func _on_s_15_pressed() -> void:
	if 15 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage15_Boss.tscn")
	else: print("Stage 15 is locked!")

func _on_s_16_pressed() -> void:
	if 16 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/PEMDAS_Tutorial1.tscn")
	else: print("Stage 16 is locked!")

func _on_s_17_pressed() -> void:
	if 17 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage16_19_NormalStage.tscn")
	else: print("Stage 17 is locked!")

func _on_s_18_pressed() -> void:
	if 18 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/Stage18_Preboss.tscn")
	else: print("Stage 18 is locked!")

func _on_s_19_pressed() -> void:
	if 19 <= PlayerData.highest_stage_unlocked:
		get_tree().change_scene_to_file("res://campaign stages/f_boss.tscn")
	else: print("Stage 19 is locked!")
