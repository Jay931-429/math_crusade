extends Node2D

# Called when the node enters the scene tree for the first time.
@onready var display_label = $AnswerLabel
@onready var problem_label = $ProblemLabel  # Add this Label node for showing the math problem
@onready var score_label = $ScoreLabel      # Add this Label node for showing the score
@onready var hp_label = $HPLabel            # Add this Label node for showing the HP
@onready var timer_label = $TimerLabel      # Add this Label node for showing the timer
@onready var player_animation = $Player  # Adjust the path based on your scene structure
@onready var enemy_animation = $Enemy2 
@onready var buddy_animation = $Buddy   # Adjust the path based on your scene structure

@onready var dialogue_box = $DialogueBox  # Panel or ColorRect
@onready var dialogue_text = $DialogueBox/DialogueText  # Label or RichTextLabel
@onready var dialogue_name = $DialogueBox/NameLabel  # Label
@onready var continue_button = $DialogueBox/ContinueButton  # TextureButton or Button
@onready var dialogue_animator = $DialogueAnimator

@onready var typewriter_timer = $TypewriterTimer # Adjust path

# --- Add references for character sprites ---
@onready var buddy_sprite = $DialogueBox/Buddy
@onready var teacher_sprite = $DialogueBox/Teacher
@onready var wiz_sprite = $DialogueBox/wizard


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
var max_time: float = 35.0   # Time limit per question in seconds
var current_time: float = 0.0 # Current time elapsed
var timer_active: bool = false # Flag to track if timer is active


var player_original_pos: Vector2
var enemy_original_pos: Vector2
var buddy_original_pos: Vector2
var attack_move_distance: float = 430.0 # How many pixels to move forward (adjust!)
var attack_move_duration: float = 0.12 # How long the forward move takes (adjust!)
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
	if wiz_sprite: # Check if the node exists
		character_sprites["wizard"] = wiz_sprite
	# Add other characters here:
	# character_sprites["AnotherNPC"] = another_npc_sprite
	
	# --- Populate the DISPLAY NAME dictionary ---
	# Map Internal ID -> Display Name
	display_names["Buddy"] = "Mathie" # Or maybe "Your Pal" if you want
	display_names["Teacher"] = "Aric"
	display_names["wizard"] = "Old Wizard" # <--- CHANGE THIS to whatever you want displayed
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
	buddy_original_pos = buddy_animation.position
	enemy_original_pos = enemy_animation.position

	# Start the first problem
	# generate_new_problem()
	AudioManager.change_music("stage6")

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

func show_tutorial_dialogue() -> void:
	# Set up tutorial dialogue
	current_dialogue = [
	{"name": "Buddy", "text": "Damn, that was tough, but we made it!"},
	{"name": "Teacher", "text": "Yeah, but what is this place? It feels as though time itself holds its breath within these walls."},
	{"name": "", "text": "(A ghostly voice echoes through the chamber.)"},
	{"name": "wizard", "text": "Welcome, young knight. I am the wizard of this tower, a guardian of forgotten knowledge. You have been drawn here for a purpose!"},
	{"name": "Teacher", "text": "(Startled, drawing his sword) Who speaks? Show yourself!"},
	{"name": "wizard", "text": "Fear not, brave warrior."},
	{"name": "wizard", "text": "My physical form has long since faded, but my essence remains within these walls, bound to the knowledge they contain."},
	{"name": "wizard", "text": "You seek the power to defeat the invading darkness, do you not?"},
	{"name": "Teacher", "text": "I do. The lost village of arithmancers spoke of ancient prophecies and the need to understand them."},
	{"name": "wizard", "text": "Indeed. And the key to deciphering those prophecies lies within the advanced principles of arithmancy."},
	{"name": "wizard", "text": "Seek the truth within these scrolls, and you shall unlock........."},
	{"name": "Buddy", "text": "Hey, Old man, enough yapping and make it quick."},
	{"name": "Buddy", "text": "The more we spend time talking, The more The Architech is getting stronger."},
	{"name": "wizard", "text": "What?! Ughh... Fine."},
	{"name": "wizard", "text": "The ancient arithmancers discovered a sacred order for solving complex calculations, known as PEMDAS."},
	{"name": "Teacher", "text": "PEMDAS? What does that mean?"},
	{"name": "wizard", "text": "It is the Order of Operations - the very foundation of advanced arithmancy."},
	{"name": "wizard", "text": "First, solve what's in Parentheses ( )."},
	{"name": "wizard", "text": "Next, calculate Exponents like squares and cubes."},
	{"name": "wizard", "text": "Then perform Multiplication and Division, from left to right."},
	{"name": "wizard", "text": "Finally, complete Addition and Subtraction, also from left to right."},
	{"name": "Buddy", "text": "So if I see something like 2 + 3 × 4, I should multiply first, then add?"},
	{"name": "wizard", "text": "Precisely! You would get 14, not 20, because multiplication comes before addition in PEMDAS."},
	{"name": "wizard", "text": "The Architech uses this knowledge to create complex magical traps. Understanding PEMDAS will let you disarm them."},
	{"name": "Teacher", "text": "And if there are parentheses like (2 + 3) × 4?"},
	{"name": "wizard", "text": "Then you solve inside the parentheses first: (2 + 3) = 5, then multiply: 5 × 4 = 20."},
	{"name": "wizard", "text": "Remember: Parentheses, Exponents, Multiplication/Division, Addition/Subtraction - PEMDAS!"},
	{"name": "Buddy", "text": "Hmm, this actually seems pretty useful."},
	{"name": "wizard", "text": "It is the key to unlocking the most powerful arithmantic spells. Master PEMDAS, and you will overcome the challenges ahead."},
	{"name": "Teacher", "text": "All right, Let's begin!"}
]

# Start displaying dialogue
	dialogue_active = true
	dialogue_index = 0
	dialogue_animator.play("dialogue_show")
	display_dialogue()

func display_dialogue() -> void:
	if dialogue_index >= current_dialogue.size():
		if typewriter_timer.time_left > 0:
			typewriter_timer.stop()
			dialogue_text.text = full_dialogue_text
		end_dialogue()
		return

	var current = current_dialogue[dialogue_index]
	var speaker_id = current.name
	dialogue_text.text = current.text

	if current.has("video") and current.video != "":
		dialogue_box.visible = false
		dialogue_text.visible = false
		dialogue_name.visible = false
		play_video(current.video)
	else:
		dialogue_box.visible = true
		dialogue_text.visible = true
		
		#  NARRATION CHECK
		if speaker_id == "":
			# Narration: center the text and hide the name
			dialogue_name.visible = false
			dialogue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			dialogue_text.position = Vector2(273.0, 83.0) # Change to fit your layout
		else:
			# Regular dialogue
			dialogue_name.visible = true
			dialogue_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			dialogue_text.position = Vector2(379.0, 83.0) # Change to your default position

		full_dialogue_text = current.text
		dialogue_text.text = ""
		typewriter_char_index = 0

	if current.has("sfx") and current.sfx != "":
		AudioManager.play_sfx(current.sfx)

	# Set speaker name
	if display_names.has(speaker_id):
		dialogue_name.text = display_names[speaker_id]
	else:
		dialogue_name.text = speaker_id

	# Character sprite visibility
	for sprite_node in character_sprites.values():
		sprite_node.visible = false

	if character_sprites.has(speaker_id):
		var active_sprite = character_sprites[speaker_id]
		active_sprite.visible = true

	if full_dialogue_text.length() > 0:
		typewriter_timer.start()
	

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
		{"name": "Buddy", "text": "Ummm....Wakey Wakey! Are you still sleepy?"},
		{"name": "Buddy", "text": "Come on bud, Stay Alert!"}
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
	if total_problems >= max_problems or current_hp <= 0:
		player_animation.position = player_original_pos
		buddy_animation.position = buddy_original_pos
		enemy_animation.position = enemy_original_pos
		end_game()
		return
	
	if !tutorial_completed:
		return
		
	question_answered = false # <<< Reset answer state for new problem

	# Reset positions and animations
	player_animation.position = player_original_pos
	enemy_animation.position = enemy_original_pos
	buddy_animation.position = buddy_original_pos
	player_animation.play("Idle")
	enemy_animation.play("Idle")
	buddy_animation.play("Idle")

	# Random numbers
	var num1 = randi() % 5 + 1
	var num2 = randi() % 5 + 1
	var num3 = randi() % 5 + 1
	var num4 = randi() % 5 + 1
	# Random operations
	var operation1 = randi() % 4  # 0:+, 1:-, 2:*, 3:/
	var operation2 = randi() % 4
	var operation3 = randi() % 4
	var op1_str = "+"
	var op2_str = "+"
	var op3_str = "+"
	var op1_func = func(a, b): return a + b
	var op2_func = func(a, b): return a + b
	var op3_func = func(a, b): return a + b
	# Assign operation 1
	if operation1 == 1:
		op1_str = "-"
		if num1 < num2:  # Ensure num1 ≥ num2 for subtraction
			var temp = num1
			num1 = num2
			num2 = temp
		op1_func = func(a, b): return a - b
	elif operation1 == 2:
		op1_str = "*"
		op1_func = func(a, b): return a * b
	elif operation1 == 3:
		op1_str = "/"
		num2 = max(1, num2)
		while num1 % num2 != 0:
			num1 = randi() % 5 + 1
			num2 = randi() % 5 + 1
		op1_func = func(a, b): return a / b
	var temp_result = op1_func.call(num1, num2)
	
	# Assign operation 2
	if operation2 == 1:
		op2_str = "-"
		if temp_result < num3:  # For subtraction, ensure temp_result ≥ num3
			var swap = num3
			num3 = temp_result
			temp_result = swap  # This preserves the result being non-negative
		op2_func = func(a, b): return a - b
	elif operation2 == 2:
		op2_str = "*"
		op2_func = func(a, b): return a * b
	elif operation2 == 3:
		op2_str = "/"
		num3 = max(1, num3)
		while int(temp_result) % num3 != 0:
			num3 = randi() % 5 + 1
		op2_func = func(a, b): return a / b
	temp_result = op2_func.call(temp_result, num3)
	
	# Assign operation 3
	if operation3 == 1:
		op3_str = "-"
		if temp_result < num4:  # For subtraction, ensure temp_result ≥ num4
			var swap = num4
			num4 = temp_result
			temp_result = swap  # This preserves the result being non-negative
		op3_func = func(a, b): return a - b
	elif operation3 == 2:
		op3_str = "*"
		op3_func = func(a, b): return a * b
	elif operation3 == 3:
		op3_str = "/"
		num4 = max(1, num4)
		while int(temp_result) % num4 != 0:
			num4 = randi() % 5 + 1
		op3_func = func(a, b): return a / b
	current_answer = int(op3_func.call(temp_result, num4))
	
	# Final problem display
	problem_label.text = "( ( " + str(num1) + " " + op1_str + " " + str(num2) + " ) " + op2_str + " " + str(num3) + " ) " + op3_str + " " + str(num4) + " = ?"
	# Clear the answer display and start timer
	clear_display()
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
			AudioManager.play_sfx("correct")

			# 1. Start Player Run Anim & Move Forward Tween
			player_animation.play("Run")
			var player_target_pos = player_original_pos + Vector2(attack_move_distance, 0)
			var player_move_tween = create_tween().set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
			player_move_tween.tween_property(player_animation, "position", player_target_pos, attack_move_duration)

			# 2. Wait for Player Forward Movement to Finish
			await player_move_tween.finished

			# 3. Start Buddy Run Anim & Move Forward Tween (AFTER Player)
			buddy_animation.play("Run")
			var buddy_target_pos = buddy_animation.position + Vector2(attack_move_distance, 0)
			var buddy_move_tween = create_tween().set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
			buddy_move_tween.tween_property(buddy_animation, "position", buddy_target_pos, attack_move_duration)

			# 4. Wait for Buddy Forward Movement to Finish
			await buddy_move_tween.finished

			# 5. Play Attack/Hit Anims and Sound
			player_animation.play("Attack")
			buddy_animation.play("Run")
			enemy_animation.play("Hit")
			AudioManager.play_sfx("ehit")

			# 6. Wait for Attack/Hit animation to have some effect
			await get_tree().create_timer(0.4).timeout

			# 7. Set player and buddy back to Idle before returning
			player_animation.play("Idle")
			buddy_animation.play("Idle")
			var return_tween = create_tween().set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_CUBIC)
			return_tween.tween_property(player_animation, "position", player_original_pos, return_move_duration)
			var buddy_return_tween = create_tween().set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_CUBIC)
			buddy_return_tween.tween_property(buddy_animation, "position", buddy_original_pos, return_move_duration)
			await return_tween.finished
			await buddy_return_tween.finished

		else:
			# --- WRONG ANSWER ---
			problem_label.text = "Wrong! Answer: " + str(current_answer)

			# 1. Start Enemy Run Anim & Move Forward Tween
			enemy_animation.play("Run")
			var enemy_target_pos = enemy_original_pos - Vector2(attack_move_distance, 0)
			var move_tween = create_tween().set_ease(Tween.EaseType.EASE_OUT).set_trans(Tween.TransitionType.TRANS_CUBIC)
			move_tween.tween_property(enemy_animation, "position", enemy_target_pos, attack_move_duration)

			# 2. Wait for Forward Movement (Running) to Finish
			await move_tween.finished

			# 3. Play Attack/Hit Anims, Sound, and Apply HP Loss
			enemy_animation.play("Attack")
			player_animation.play("Hit")
			AudioManager.play_sfx("wrong")
			lose_hp()

			# Optional Feedback Dialogue
			if current_hp <= 3 && current_hp > 0:
				show_feedback_dialogue([
					{"name": "Buddy", "text": "Be careful! You Ok?"},
					{"name": "Teacher", "text": "No Worries, I'm Alright"}
				])

			# 4. Wait for Attack/Hit animation to have some effect
			await get_tree().create_timer(0.4).timeout

			# 5. Set enemy back to Idle before returning
			enemy_animation.play("Idle")
			var return_tween = create_tween().set_ease(Tween.EaseType.EASE_IN).set_trans(Tween.TransitionType.TRANS_CUBIC)
			return_tween.tween_property(enemy_animation, "position", enemy_original_pos, return_move_duration)
			await return_tween.finished

			# 6. Check if game ended due to HP loss AFTER animation/movement/return
			if current_hp <= 0:
				end_game()
				return

		# --- COMMON LOGIC ---
		total_problems += 1
		score_label.text = str(score) + "/" + str(total_problems)

		if total_problems >= max_problems or current_hp <= 0:
			await get_tree().create_timer(0.3).timeout
			end_game()
		else:
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

	if player_won:
		current_dialogue = [
			{"name": "Buddy", "text": "Finally, One step closer to the Architect!"},
			{"name": "Teacher", "text": "Agree."},
			{"name": "wizard", "text": "With these new skills, you will be able to solve even the most difficult mathematical puzzles."},
			{"name": "wizard", "text": "Now, go forth and use your newfound knowledge to defeat the Architect and save Numeria!
"},
			{"name": "Teacher", "text": "Understood, We'll be on our way!"}
		]
	else:
		current_dialogue = [
			{"name": "Buddy", "text": "Hey Bud? Hey! Are you OK?"},
			{"name": "Buddy", "text": "Time for us to get out of here, i suppose."}
		]

	dialogue_active = true
	dialogue_index = 0
	dialogue_animator.play("dialogue_show")
	display_dialogue()

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

	# Show the end stage dialogue
	show_end_stage_dialogue()

	# Wait for the dialogue to finish
	await _wait_for_dialogue_finish()
	
	PlayerData.complete_stage(16)

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
	
func play_video(video_path: String) -> void:
	var video_player = VideoStreamPlayer.new()
	add_child(video_player)
	video_player.stream = load(video_path)
	video_player.play()
	video_player.finished.connect(_on_video_finished.bind(video_player))
#
func _on_video_finished(video_player):
	video_player.queue_free() # Remove video player
	dialogue_index += 1 # Advance dialogue
	display_dialogue() # Resume dialogue
