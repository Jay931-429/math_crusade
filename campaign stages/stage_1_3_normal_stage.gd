extends Node2D

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


# Stage Information
var current_stage_path: String = ""  # Will be set dynamically
var next_stage_path: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get the current stage path dynamically
	current_stage_path = get_tree().current_scene.scene_file_path
	
	# Determine the next stage dynamically
	next_stage_path = GameData.get_next_stage(current_stage_path)
	
	# Initialize HP display
	update_hp_display()

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
	problem_label.text = "Time's up! Answer: " + str(current_answer)
	lose_hp()
	player_animation.play("Hit")  # Player takes damage animation
	enemy_animation.play("Attack")
	total_problems += 1
	score_label.text = str(score) + "/" + str(total_problems)

	# Check if game should end due to max problems
	if total_problems >= max_problems:
		await get_tree().create_timer(2.0).timeout
		end_game()
	else:
		# Wait 2 seconds before next problem
		await get_tree().create_timer(0.5).timeout
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
	player_animation.play("Idle")
	enemy_animation.play("Idle")
	
	# Generate two random numbers between 1 and 20
	var num1 = randi() % 20 + 1
	var num2 = randi() % 20 + 1

	# Only do addition problems
	current_answer = num1 + num2
	problem_label.text = str(num1) + " + " + str(num2) + " = "

	# Clear the answer display
	clear_display()

	# Start the timer for this question
	start_timer()


func check_answer() -> void:
	if current_text != "":
		timer_active = false
		var player_answer = int(current_text)

		if player_answer == current_answer:
			score += 1
			problem_label.text = "Correct!"
			player_animation.play("Attack")  # Play player's attack animation
			enemy_animation.play("Hit")  # Play enemy hit animation
			AudioManager.play_sfx("correct") # Play correct answer sound
		else:
			problem_label.text = "Wrong! Answer: " + str(current_answer)
			lose_hp()
			player_animation.play("Hit")  # Player takes damage animation
			enemy_animation.play("Attack")
			AudioManager.play_sfx("wrong")  # Play incorrect answer sound

		await get_tree().create_timer(0.5).timeout  # Wait before next question
		total_problems += 1
		score_label.text = str(score) + "/" + str(total_problems)

		if total_problems >= max_problems || current_hp <= 0:
			await get_tree().create_timer(0.5).timeout
			end_game()
		else:
			await get_tree().create_timer(0.5).timeout
			generate_new_problem()

func end_game() -> void:
	timer_active = false
	var player_won = score >= target_score && current_hp > 0

	GameData.set_results_data({
		"player_score": score,
		"max_score": total_problems,
		"player_won": player_won,
		"current_stage": current_stage_path,
		"next_stage": next_stage_path if player_won else "",
		"remaining_hp": current_hp,
		"max_hp": max_hp
	})

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
