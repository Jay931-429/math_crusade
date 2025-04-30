extends Node2D

# Called when the node enters the scene tree for the first time.
@onready var display_label = $AnswerLabel
@onready var problem_label = $ProblemLabel  # Add this Label node for showing the math problem
@onready var score_label = $ScoreLabel      # Add this Label node for showing the score
@onready var hp_label = $HPLabel            # Add this Label node for showing the HP
@onready var timer_label = $TimerLabel      # Add this Label node for showing the timer
@onready var player_animation = $Player  # Adjust the path based on your scene structure
@onready var enemy_animation = $Enemy2   # Adjust the path based on your scene structure

@onready var dialogue_box = $DialogueBox  # Panel or ColorRect
@onready var dialogue_text = $DialogueBox/DialogueText  # Label or RichTextLabel
@onready var dialogue_name = $DialogueBox/NameLabel  # Label
@onready var continue_button = $DialogueBox/ContinueButton  # TextureButton or Button
@onready var dialogue_animator = $DialogueAnimator

@onready var typewriter_timer = $TypewriterTimer # Adjust path

# --- Add references for character sprites ---
@onready var buddy_sprite = $DialogueBox/Buddy
@onready var teacher_sprite = $DialogueBox/Teacher


var full_dialogue_text: String = ""
var typewriter_char_index: int = 0
var dialogue_active: bool = false
var current_dialogue = []
var dialogue_index: int = 0
var tutorial_completed: bool = false

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
var max_time: float = 30.0   # Time limit per question in seconds
var current_time: float = 0.0 # Current time elapsed
var timer_active: bool = false # Flag to track if timer is active


var player_original_pos: Vector2
var enemy_original_pos: Vector2
var attack_move_distance: float = 430.0 # How many pixels to move forward (adjust!)
var attack_move_duration: float = 0.2 # How long the forward move takes (adjust!)
var return_move_duration: float = 0.1 # How long the return move takes (adjust!)

# --- Dictionary to map speaker names to sprites ---
var character_sprites: Dictionary = {}
# --- Dictionary to map speaker IDs to DISPLAY NAMES ---
var display_names: Dictionary = {}

var question_answered: bool = false

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
	
	dialogue_box.visible = false
	
		# --- Populate the character sprite dictionary ---
	# Make sure the keys ("Buddy", "Teacher") EXACTLY match the "name"
	# used in your dialogue data arrays.
	if buddy_sprite: # Check if the node exists before adding
		character_sprites["Buddy"] = buddy_sprite
	if teacher_sprite: # Check if the node exists
		character_sprites["Teacher"] = teacher_sprite
	# Add other characters here:
	# character_sprites["AnotherNPC"] = another_npc_sprite
	
	# --- Populate the DISPLAY NAME dictionary ---
	# Map Internal ID -> Display Name
	display_names["Buddy"] = "Aric" # Or maybe "Your Pal" if you want
	display_names["Teacher"] = "Lady Hilda" # <--- CHANGE THIS to whatever you want displayed
	# Add other characters if needed
	# display_names["Boss"] = "Dark Lord Malakor"
	
# Show initial tutorial dialogue
	show_tutorial_dialogue()
	
	if !tutorial_completed:
		problem_label.text = ""  # Hide problem during tutorial
	else:
		generate_new_problem()
	
	
	 # Store initial positions for movement
	player_original_pos = player_animation.position
	enemy_original_pos = enemy_animation.position

	# Start the first problem
	# generate_new_problem()
	AudioManager.change_music("stage1")

# Called every frame
func _process(delta: float) -> void:
	if dialogue_active:
		if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_select"):
			# Check if typewriter is running
			if typewriter_timer.time_left > 0:
				 # If yes, stop timer and show full text instantly
				typewriter_timer.stop()
				dialogue_text.text = full_dialogue_text
				 # Ensure index is at the end so next press advances dialogue
				typewriter_char_index = full_dialogue_text.length()
			else:
				 # If typewriter finished, advance to next dialogue line
				next_dialogue()
		return # Don't process game logic during dialogue

	
	# Your existing timer logic
	if timer_active:
		current_time -= delta
		update_timer_display()
		if current_time <= 0:
			timer_active = false
			time_up()

func update_hp_display() -> void:
	# Update the HP display with hearts or text
	hp_label.text = "❤".repeat(current_hp)

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

func show_tutorial_dialogue() -> void:
	# Set up tutorial dialogue
	current_dialogue = [
		{"name": "Teacher", "text": "Welcome to the Training Ground, Aric!"},
		{"name": "Teacher", "text": "Today, We will begin your combat training."},
		{"name": "Teacher", "text": "Remember, to beat your enemy,give the correct answer."},
		{"name": "Teacher", "text": "Use the number buttons to input your answer, then press Submit."},
		{"name": "Teacher", "text": "Giving out the wrong answer cost you health points."},
		{"name": "Teacher", "text": "Also, being too slow running out of time will cost you health points."},
		{"name": "Teacher", "text": "Understood?"},
		{"name": "Buddy", "text": "Yes, Lady Hilda!"},
		{"name": "Teacher", "text": "For now, i will spar with you"},
		{"name": "Teacher", "text": "Don't Worry, Ill go easy on you"},
		{"name": "Buddy", "text": "Yes, Lady Hilda!"},
		{"name": "Teacher", "text": "All right, Let's begin!"}
	]
# Start displaying dialogue
	dialogue_active = true
	dialogue_index = 0
	dialogue_animator.play("dialogue_show")
	display_dialogue()

func display_dialogue() -> void:
	if dialogue_index >= current_dialogue.size():
		# If skipping animation, ensure full text is shown before ending
		if typewriter_timer.time_left > 0:
			typewriter_timer.stop()
			dialogue_text.text = full_dialogue_text # Show full text instantly
		end_dialogue()
		return

	var current = current_dialogue[dialogue_index]
	# KEEP using current.name as the INTERNAL identifier for sprite lookup
	var speaker_id = current.name
	dialogue_text.text = current.text # Text remains the same
	
	
	# --- Store full text, clear label, reset index ---
	full_dialogue_text = current.text
	dialogue_text.text = "" # Clear text label
	typewriter_char_index = 0
	# --- End setup ---

	# --- Set the DISPLAY NAME using the new dictionary ---
	if display_names.has(speaker_id):
		# If we have a specific display name mapped, use it
		dialogue_name.text = display_names[speaker_id]
	else:
		# Otherwise, fall back to using the internal ID as the name
		dialogue_name.text = speaker_id
	# --- End setting display name ---


	# --- Logic to show/hide character sprites (NO CHANGE NEEDED HERE) ---
	# This part STILL uses the internal speaker_id ("Teacher", "Buddy")
	# to find the correct sprite in character_sprites.
	# 1. Hide all character sprites first
	for sprite_node in character_sprites.values():
		sprite_node.visible = false

	# 2. Get the current speaker's internal ID (already done above)
	# var speaker_id = current.name

	# 3. Check if this speaker ID has a mapped sprite and show it
	if character_sprites.has(speaker_id):
		var active_sprite = character_sprites[speaker_id]
		active_sprite.visible = true

	# --- Start Typewriter Effect ---
	# Don't start if text is empty
	if full_dialogue_text.length() > 0:
		typewriter_timer.start() # Use timer's wait_time
	# --- End Start Typewriter ---

func next_dialogue() -> void:
	dialogue_index += 1
	display_dialogue()

func end_dialogue() -> void:
	# Don't set dialogue_active false yet
	# dialogue_box.visible = false # Remove this

	# --- Hide all character sprites when dialogue ends ---
	for sprite_node in character_sprites.values():
		sprite_node.visible = false
	# --- End hide sprites ---

	# Play hide animation and wait for it
	dialogue_animator.play("dialogue_hide")
	await dialogue_animator.animation_finished # Wait here

	# Now fully deactivate dialogue state
	dialogue_active = false

	# Now that tutorial is done, start the game (if needed)
	if !tutorial_completed:
		tutorial_completed = true
		generate_new_problem()
		
func _on_continue_button_pressed() -> void:
	if typewriter_timer.time_left > 0:
		# Typewriter is still running — complete the text instantly
		typewriter_timer.stop()
		dialogue_text.text = full_dialogue_text
		typewriter_char_index = full_dialogue_text.length()
	else:
		# Text is fully shown — move to next line
		next_dialogue()

func show_time_up_dialogue():
	# Define the dialogue lines for running out of time
	# You can have one or more characters speak
	current_dialogue = [
		{"name": "Teacher", "text": "Too slow! Time ran out on that one."},
		{"name": "Teacher", "text": "'Speed defines the winner' as they say."},
		{"name": "Teacher", "text": "Move like that on the battlefield"},
		{"name": "Teacher", "text": "You'd be a goner soon enough!"}
		# Or just one speaker:
		# {"name": "Teacher", "text": "Time's up! You need to answer faster."}
	]

	# --- Activate the dialogue system ---
	dialogue_active = true
	dialogue_index = 0 # Start from the beginning of this dialogue
	dialogue_animator.play("dialogue_show") # Or use animation player later
	display_dialogue() # Display the first line
	
func time_up() -> void:
	# --- TIME UP (Treated as Incorrect) ---
	problem_label.text = "Time's up! Answer: " + str(current_answer)

	# 1. Start Enemy Run Anim & Move Forward Tween
	enemy_animation.play("Run")
	var enemy_target_pos = enemy_original_pos - Vector2(attack_move_distance, 0)
	# Line 235 Correction:
	var move_tween = create_tween().set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
	move_tween.tween_property(enemy_animation, "position", enemy_target_pos, attack_move_duration)

	# 2. Wait for Forward Movement (Running) to Finish
	await move_tween.finished

	# 3. Play Attack/Hit Anims and Apply HP Loss (Now that enemy arrived)
	enemy_animation.play("Attack")
	player_animation.play("Hit")
	AudioManager.play_sfx("timeup")
	lose_hp()

	# 4. Wait for Attack/Hit animation to have some effect
	await get_tree().create_timer(0.4).timeout

	# 5. Set enemy back to Idle before returning
	enemy_animation.play("Idle")
	# Line 252 Correction:
	var return_tween = create_tween().set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_CUBIC)
	return_tween.tween_property(enemy_animation, "position", enemy_original_pos, return_move_duration)
	await return_tween.finished
	
	# --- ADD DIALOGUE CALL HERE ---
	# Check if game hasn't already ended due to HP loss from this attack
	if current_hp > 0:
		show_time_up_dialogue()
		 # Wait for the dialogue to finish before proceeding
		 # (Important: Dialogue sets dialogue_active=true, _process handles advancing it)
		while dialogue_active:
			await get_tree().process_frame # Wait one frame
		 # OR, if dialogue auto-advances/ends, await a signal or timer
	# -----------------------------


	# 6. Check if game ended due to HP loss AFTER animation/movement/return
	if current_hp <= 0:
		end_game()
		return

	# --- COMMON LOGIC ---
	# (Code remains the same here)
	total_problems += 1
	score_label.text = str(score) + "/" + str(total_problems)

	if total_problems >= max_problems or current_hp <= 0:
		await get_tree().create_timer(0.3).timeout
		end_game()
	else:
		await get_tree().create_timer(0.1).timeout
		generate_new_problem()
		
func lose_hp() -> void:
	# Decrease HP and update display
	if current_hp > 0: # Prevent HP going below 0 visually
		current_hp -= 1
		update_hp_display()

	# Play damage sound if available
	AudioManager.play_sfx("phit")

	# Check if out of HP - NO LONGER CALLS END_GAME HERE
	# The check and call to end_game() will happen after animations/movement

	# Play damage sound if available
	# AudioManager.play_sound("damage")

	# Check if out of HP
	if current_hp <= 0:
		await get_tree().create_timer(1.0).timeout
		end_game()

func generate_new_problem() -> void:
	   # Check if game should end (handle HP=0 case here too)
	if total_problems >= max_problems or current_hp <= 0:
		# Ensure positions are reset before potential end game transition if HP was 0
		player_animation.position = player_original_pos
		enemy_animation.position = enemy_original_pos
		end_game()
		return
	if !tutorial_completed:
		return  # Don't generate problems if tutorial isn't finished
		
	question_answered = false # <<< Reset answer state for new problem

	# Reset positions before setting Idle animation
	player_animation.position = player_original_pos
	enemy_animation.position = enemy_original_pos

	player_animation.play("Idle")
	enemy_animation.play("Idle")
	
	# Generate two random numbers between 1 and 20
	var num1 = randi() % 5 + 1
	var num2 = randi() % 5 + 1

	# Only do addition problems
	current_answer = num1 + num2
	problem_label.text = str(num1) + " + " + str(num2) + " = ?"

	# Clear the answer display
	clear_display()

	# Start the timer for this question
	start_timer()


func check_answer() -> void:
	if question_answered:
		return # Prevent double-answering the same question

	if current_text != "":
		timer_active = false
		var player_answer = int(current_text)
		
		question_answered = true # Lock the current question once answered

		if player_answer == current_answer:
			# --- CORRECT ANSWER ---
			score += 1
			problem_label.text = "Correct!"

			# 1. Start Player Run Anim & Move Forward Tween
			player_animation.play("Run")
			var player_target_pos = player_original_pos + Vector2(attack_move_distance, 0)
			var move_tween = create_tween().set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
			move_tween.tween_property(player_animation, "position", player_target_pos, attack_move_duration)

			# 2. Wait for Forward Movement (Running) to Finish
			await move_tween.finished

			# 3. Play Attack/Hit Anims and Sound (Now that player arrived)
			player_animation.play("Attack")
			enemy_animation.play("Hit") # Enemy *reacts* (Hit), but doesn't *attack*
			AudioManager.play_sfx("correct")
			AudioManager.play_sfx("ehit")

			# --- REMOVE ANY ENEMY ATTACK LOGIC FROM HERE ---
			# Make sure there are NO lines here like:
			# enemy_animation.play("Run")
			# move_tween.tween_property(enemy_animation, ...)
			# enemy_animation.play("Attack")
			# lose_hp()
			# --- END REMOVAL ZONE ---

			# Optional Feedback Dialogues
			if score == 1:
				show_feedback_dialogue([
					{"name": "Teacher", "text": "Great job, Keep it Up"},
					{"name": "Teacher", "text": "Keep it up! You need more correct answers to win."}
				])
			elif score == target_score - 1:
				show_feedback_dialogue([
					{"name": "Teacher", "text": "Your Skills are impressive!"}
				])

			# 4. Wait for Attack/Hit animation to have some effect
			await get_tree().create_timer(0.4).timeout

			# 5. Set player back to Idle before returning
			player_animation.play("Idle")
			var return_tween = create_tween().set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_CUBIC)
			return_tween.tween_property(player_animation, "position", player_original_pos, return_move_duration)
			await return_tween.finished

		else:
			# --- WRONG ANSWER ---
			# (This block should *only* contain the enemy attack logic)
			problem_label.text = "Wrong! Answer: " + str(current_answer)

			# 1. Start Enemy Run Anim & Move Forward Tween
			enemy_animation.play("Run")
			var enemy_target_pos = enemy_original_pos - Vector2(attack_move_distance, 0)
			var move_tween = create_tween().set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
			move_tween.tween_property(enemy_animation, "position", enemy_target_pos, attack_move_duration)

			# 2. Wait for Forward Movement (Running) to Finish
			await move_tween.finished

			# 3. Play Attack/Hit Anims, Sound, and Apply HP Loss (Now that enemy arrived)
			enemy_animation.play("Attack")
			player_animation.play("Hit") # Player gets hit
			AudioManager.play_sfx("wrong")
			lose_hp() # Player loses HP

			# Optional Feedback Dialogue
			if current_hp <= 3 && current_hp > 0:
				show_feedback_dialogue([
					{"name": "Teacher", "text": "Be careful! Your health is getting low."},
					{"name": "Teacher", "text": "Take your time with the next problem."}
				])

			# 4. Wait for Attack/Hit animation to have some effect
			await get_tree().create_timer(0.4).timeout

			# 5. Set enemy back to Idle before returning
			enemy_animation.play("Idle")
			var return_tween = create_tween().set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_CUBIC)
			return_tween.tween_property(enemy_animation, "position", enemy_original_pos, return_move_duration)
			await return_tween.finished

			# 6. Check if game ended due to HP loss AFTER animation/movement/return
			#    (This check might be redundant with the one in COMMON LOGIC, but ok for now)
			if current_hp <= 0:
				end_game()
				return # Important: return here to avoid common logic if game ended

		# --- COMMON LOGIC --- (This runs after EITHER correct or wrong answer logic finishes)
		total_problems += 1
		score_label.text = str(score) + "/" + str(total_problems)

		# Check end conditions (Ran out of problems OR ran out of HP)
		if total_problems >= max_problems or current_hp <= 0:
			# Short delay before ending allows animations to fully finish visually
			await get_tree().create_timer(0.3).timeout
			end_game()
		else:
			# Short delay before generating next problem
			await get_tree().create_timer(0.1).timeout
			generate_new_problem()
			
# New function for contextual feedback
func show_feedback_dialogue(dialogue_data) -> void:
	# Only show feedback if tutorial is completed
	if !tutorial_completed:
		return
		
	current_dialogue = dialogue_data
	dialogue_active = true
	dialogue_index = 0
	dialogue_animator.play("dialogue_show")
	display_dialogue()
	
	# Pause timer while showing feedback
	if timer_active:
		timer_active = false

func show_end_stage_dialogue() -> void:
	var player_won = score >= target_score && current_hp > 0
	var survived_all = GameData.get_results_data().get("survived_all", false)


	if player_won:
		current_dialogue = [
			{"name": "Teacher", "text": "Congratulations, you've completed your training today."},
			{"name": "Teacher", "text": "You're Dismissed, Knight!"},
			{"name": "Teacher", "text": "Wait....."},
			{"name": "Buddy", "text": "What is it, Lady Hilda?"},
			{"name": "Teacher", "text": "I received a message from the King."},
			{"name": "Teacher", "text": "You are to report to him immediately!"},
			{"name": "Buddy", "text": "Understood, I'll be on my way!"}
		]
	elif survived_all:
		current_dialogue = [
			{"name": "Teacher", "text": "Let's try again and push a little harder next time!"}
		]
	else:
		current_dialogue = [
			{"name": "Teacher", "text": "Well, maybe you still need time to train"},
			{"name": "Teacher", "text": "Let's review your performance and try again."}
		]

	dialogue_active = true
	dialogue_index = 0
	dialogue_animator.play("dialogue_show")
	display_dialogue()

func end_game() -> void:
	timer_active = false
	var survived_all = total_problems >= max_problems and current_hp > 0
	var player_won = score >= target_score and survived_all

	GameData.set_results_data({
		"player_score": score,
		"max_score": total_problems,
		"player_won": player_won,
		"current_stage": current_stage_path,
		"next_stage": next_stage_path if player_won else "",
		"remaining_hp": current_hp,
		"max_hp": max_hp,
		"survived_all": survived_all
	})

# Save for UI
	GameData.player_survived_but_failed = survived_all and not player_won

	# Show the end stage dialogue
	show_end_stage_dialogue()

	# Wait for the dialogue to finish
	await _wait_for_dialogue_finish()

	# Transition to the after_stage scene
	get_tree().change_scene_to_file("res://after_stage.tscn")

# Helper function to wait for dialogue to finish
func _wait_for_dialogue_finish() -> void:
	while dialogue_active:
		await get_tree().process_frame

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


func _on_typewriter_timer_timeout():
	if typewriter_char_index < full_dialogue_text.length():
		# Add next character
		dialogue_text.text += full_dialogue_text[typewriter_char_index]
		typewriter_char_index += 1
		# Start timer again for the next character
		typewriter_timer.start() # Uses its wait_time property
	# else: # All characters displayed, do nothing, timer stays stopped.
