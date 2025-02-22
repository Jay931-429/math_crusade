extends Node2D

# Stage for testing purpose only
# Called when the node enters the scene tree for the first time.


@onready var display_label = $Label
@onready var problem_label = $ProblemLabel  # Add this Label node for showing the math problem
@onready var score_label = $ScoreLabel      # Add this Label node for showing the score

var current_text = ""
var max_digits = 10
var current_answer: int = 0  # Stores the correct answer
var score: int = 0
var total_problems: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_new_problem()
	AudioManager.change_music("stage")

func generate_new_problem() -> void:
	# Generate two random numbers between 1 and 20
	var num1 = randi() % 20 + 1
	var num2 = randi() % 20 + 1
	
	# Randomly choose operation (0: addition, 1: subtraction, 2: multiplication)
	var operation = randi() % 3
	
	match operation:
		0:  # Addition
			current_answer = num1 + num2
			problem_label.text = str(num1) + " + " + str(num2) + " = ?"
		1:  # Subtraction
			# Ensure larger number comes first
			if num2 > num1:
				var temp = num1
				num1 = num2
				num2 = temp
			current_answer = num1 - num2
			problem_label.text = str(num1) + " - " + str(num2) + " = ?"
		2:  # Multiplication
			current_answer = num1 * num2
			problem_label.text = str(num1) + " × " + str(num2) + " = ?"
	
	# Clear the answer display
	clear_display()

func check_answer() -> void:
	if current_text != "":
		var player_answer = int(current_text)
		if player_answer == current_answer:
			score += 1
			problem_label.text = "Correct!"
		else:
			problem_label.text = "Wrong! The answer was " + str(current_answer)
		
		total_problems += 1
		score_label.text = "Score: " + str(score) + "/" + str(total_problems)
		
		# Wait 2 seconds before next problem
		await get_tree().create_timer(2.0).timeout
		generate_new_problem()

func add_number(number: String) -> void:
	if current_text.length() < max_digits:
		current_text += number
		display_label.text = current_text

func clear_display() -> void:
	current_text = ""
	display_label.text = ""

func backspace() -> void:
	if current_text.length() > 0:
		current_text = current_text.substr(0, current_text.length() - 1)
		display_label.text = current_text if current_text != "" else ""

# Button handlers
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

func _on_clear_pressed() -> void:
	clear_display()

	
func _on_back_pressed() -> void:
	backspace()

func _on_submit_pressed() -> void:
	check_answer()


func _on_placeholder_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mode_select.tscn")
