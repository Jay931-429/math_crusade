extends Node2D

# Stage for testing purpose only
# Called when the node enters the scene tree for the first time.


@onready var display_label = $Label
var current_text = ""
var max_digits = 10  # Maximum number of digits allowed


func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Its Purpose is to bring the user back to mode select
# For testing purpose only
func _on_placeholder_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")


func display_single_number(number: String) -> void:
	display_label.text = number

# Method 2: Add numbers sequentially (calculator style)
func add_number(number: String) -> void:
	if current_text.length() < max_digits:
		current_text += number
		display_label.text = current_text

# Method 3: Format as comma-separated numbers
func add_number_formatted(number: String) -> void:
	if current_text.length() < max_digits:
		current_text += number
		# Format with commas (e.g., 1,234,567)
		var formatted = format_number(current_text)
		display_label.text = formatted

# Helper function to format numbers with commas
func format_number(number_string: String) -> String:
	var result = ""
	var count = 0
	
	# Add commas from right to left
	for i in range(number_string.length() - 1, -1, -1):
		if count == 3:
			result = "," + result
			count = 0
			result = number_string[i] + result
			count += 1
	return result

# Clear the display
func clear_display() -> void:
	current_text = ""
	display_label.text = ""

# Backspace function
func backspace() -> void:
	if current_text.length() > 0:
		current_text = current_text.substr(0, current_text.length() - 1)
		display_label.text = current_text if current_text != "" else "0"
		
func _on_zero_pressed() -> void:
	add_number("0")


func _on_one_pressed() -> void:
	add_number("1")


func _on_two_pressed() -> void:
	add_number("2")


func _on_three_pressed() -> void:
	add_number("3")


func _on_four_pressed() -> void:
	add_number("4")


func _on_five_pressed() -> void:
	add_number("5")


func _on_six_pressed() -> void:
	add_number("6")


func _on_seven_pressed() -> void:
	add_number("7")


func _on_eight_pressed() -> void:
	add_number("8")


func _on_nine_pressed() -> void:
	add_number("9")
	
func _on_button_clear_pressed() -> void:
	clear_display()

func _on_button_backspace_pressed() -> void:
	backspace()
