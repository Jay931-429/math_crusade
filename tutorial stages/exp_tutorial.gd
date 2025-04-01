extends Node2D
# Stage for testing purpose only
# Called when the node enters the scene tree for the first time.
@onready var display_label = $AnswerLabel
@onready var problem_label = $ProblemLabel  # Add this Label node for showing the math problem
@onready var score_label = $ScoreLabel      # Add this Label node for showing the score
@onready var hp_label = $HPLabel            # Add this Label node for showing the HP
@onready var timer_label = $TimerLabel      # Add this Label node for showing the timer
@onready var player_animation = $Player  # Adjust the path based on your scene structure
@onready var enemy_animation = $Enemy2   # Adjust the path based on your scene structure

var current_text = ""
var max_digits = 10
var current_answer: int = 0  # Stores the correct answer
var score: int = 0
var total_problems: int = 0
var target_score: int = 8    # Win condition: need 8 correct answers
var max_problems: int = 10   # Total problems to attempt before game ends

# HP System variables
var max_hp: int = 10          # Maximum health points
var current_hp: int = 10      # Current health points

# Timer System variables
var max_time: float = 10.0   # Time limit per question in seconds
var current_time: float = 0.0 # Current time elapsed
var timer_active: bool = false # Flag to track if timer is active

var tutorial_mode: bool = true  # Set to true for tutorial, false for normal mode
var tutorial_questions = [
	{"num1": 2, "num2": 3, "operator": "^", "answer": 8, "explanation": "2^3 means 2×2×2 = 8"},
	{"num1": 3, "num2": 2, "operator": "^", "answer": 9, "explanation": "3^2 means 3×3 = 9"},
	{"num1": 5, "num2": 2, "operator": "^", "answer": 25, "explanation": "5^2 means 5×5 = 25"},
	{"num1": 10, "num2": 2, "operator": "^", "answer": 100, "explanation": "10^2 means 10×10 = 100"},
	{"num1": 2, "num2": 4, "operator": "^", "answer": 16, "explanation": "2^4 means 2×2×2×2 = 16"}
]
var current_question_index: int = 0
var show_explanation: bool = true  # Set to true to show explanations in tutorial mode


# Stage information for navigation
var current_stage_path: String = "res://Stage1_3_NormalStage.tscn"  # Update with your actual path
var next_stage_path: String = "res://test_stage_PEMDAS.tscn"    # Update with your next stage path

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize HP display
	update_hp_display()
	
	# You might want to display a tutorial instruction
	problem_label.text = "Welcome to the tutorial! Press any number to begin."
	await get_tree().create_timer(3.0).timeout

	# Start the first problem
	generate_new_problem()
	AudioManager.change_music("stage1")

# Called every frame
func _process(delta: float) -> void:
	if timer_active:
		# Update the timer
		current_time -= delta

		# Update timer display
		update_timer_display()

		# Check if time has run out
		if current_time <= 0:
			timer_active = false
			time_up()

func update_hp_display() -> void:
	# Update the HP display with hearts or text
	hp_label.text = "❤ ".repeat(current_hp)

func update_timer_display() -> void:
	# Update the timer display
	var seconds = int(current_time)
	var milliseconds = int((current_time - seconds) * 10)
	timer_label.text = "%d.%d" % [seconds, milliseconds]

	# Change color based on remaining time
	if current_time <= 3.0:
		timer_label.add_theme_color_override("font_color", Color(1, 0, 0)) # Red
	else:
		timer_label.remove_theme_color_override("font_color") # Default color

func start_timer() -> void:
	# Reset and start the timer
	current_time = max_time
	timer_active = true
	update_timer_display()

func time_up() -> void:
	# What happens when time is up for a question
	problem_label.text = "Time's up! The answer was " + str(current_answer)
	lose_hp()
	total_problems += 1
	score_label.text = str(score) + "/" + str(total_problems)

	# Check if game should end due to max problems
	if total_problems >= max_problems:
		await get_tree().create_timer(2.0).timeout
		end_game()
	else:
		# Wait 2 seconds before next problem
		await get_tree().create_timer(2.0).timeout
		generate_new_problem()

func lose_hp() -> void:
	# Decrease HP and update display
	current_hp -= 1
	update_hp_display()

	# Play damage sound if available
	# AudioManager.play_sound("damage")

	# Check if out of HP
	if current_hp <= 0:
		await get_tree().create_timer(1.0).timeout
		end_game()

func generate_new_problem() -> void:
	# Check if game should end
	if total_problems >= max_problems || current_hp <= 0:
		end_game()
		return
		
	if tutorial_mode and current_question_index < tutorial_questions.size():
		# Use predefined tutorial question for exponents
		var question = tutorial_questions[current_question_index]
		var num1 = question["num1"]
		var num2 = question["num2"]
		var operator = question["operator"]
		current_answer = question["answer"]
		
		# Display the problem with exponent notation
		problem_label.text = str(num1) + operator + str(num2) + " = ?"
		current_question_index += 1
	else:
		# Generate random exponent problem
		var base = randi() % 10 + 2  # Base between 2 and 11
		var exponent = randi() % 3 + 2  # Exponent between 2 and 4 to keep answers manageable
		current_answer = pow(base, exponent)  # Using Godot's pow function for exponentiation
		problem_label.text = str(base) + "^" + str(exponent) + " = ?"
	
	# Clear the answer display and start the timer
	clear_display()
	start_timer()

func check_answer() -> void:
	if current_text != "":
		# Stop the timer
		timer_active = false

		var player_answer = int(current_text)
		if player_answer == current_answer:
			score += 1
			if tutorial_mode and show_explanation and current_question_index <= tutorial_questions.size():
				# Show explanation for correct answer in tutorial
				problem_label.text = "Correct! " + tutorial_questions[current_question_index-1]["explanation"]
			else:
				problem_label.text = "Correct!"
			# Play correct sound if available
			#AudioManager.play_sound("correct")
		else:
			if tutorial_mode and show_explanation and current_question_index <= tutorial_questions.size():
				# Show explanation when incorrect in tutorial
				problem_label.text = "The answer was " + str(current_answer) + ". " + tutorial_questions[current_question_index-1]["explanation"]
			else:
				problem_label.text = "Wrong! The answer was " + str(current_answer)
			lose_hp()
			# Play wrong sound if available
			#AudioManager.play_sound("wrong")

		total_problems += 1
		score_label.text = str(score) + "/" + str(total_problems)

		# If we've reached max_problems or out of HP, end the game
		if total_problems >= max_problems || current_hp <= 0:
			await get_tree().create_timer(2.0).timeout  # Longer wait time to read explanation
			end_game()
		else:
			# Wait longer in tutorial mode to read explanation
			var wait_time = 2.5 if tutorial_mode else 0.5
			await get_tree().create_timer(wait_time).timeout
			generate_new_problem()

func end_game() -> void:
	# Stop the timer
	timer_active = false

	# Check win condition: enough score AND still has HP
	var player_won = score >= target_score && current_hp > 0

	# Use autoload to store the game results data
	GameData.set_results_data({
		"player_score": score,
		"max_score": total_problems,
		"player_won": player_won,
		"current_stage": current_stage_path,
		"next_stage": next_stage_path if player_won else "",
		"remaining_hp": current_hp,  # Pass HP information to results screen
		"max_hp": max_hp
	})

	# Transition to results stage
	get_tree().change_scene_to_file("res://after_stage.tscn")

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
