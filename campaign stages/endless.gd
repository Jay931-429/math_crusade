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
@onready var enemy2_animation = $Enemy3

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

@onready var video_container = $VideoContainer

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
#var target_score: int = 8    # Win condition: need 8 correct answers
#var max_problems: int = 10   # Total problems to attempt before game ends

# HP System variables
var max_hp: int = 10          # Maximum health points
var current_hp: int = 10      # Current health points

# Timer System variables
var max_time: float = 25.0   # Time limit per question in seconds
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
	display_names["wizard"] = "The Architect" # <--- CHANGE THIS to whatever you want displayed
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
	AudioManager.change_music("endless")

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
	{"name": "", "text": "Endless Mode Begins "}
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
	
	if current.has("video") and current.video != "":
		# Play video
		dialogue_box.visible = false
		dialogue_text.visible = false
		dialogue_name.visible = false
		play_video(current.video) # Call function to play video
		
	else:
		# Display dialogue text (existing code)
		dialogue_box.visible = true
		dialogue_text.visible = true
		dialogue_name.visible = true
		full_dialogue_text = current.text
		dialogue_text.text = ""
		typewriter_char_index = 0
	
	
	# --- Store full text, clear label, reset index ---
	full_dialogue_text = current.text
	dialogue_text.text = "" # Clear text label
	typewriter_char_index = 0
	# --- End setup ---
	
		# Play SFX if specified
	if current.has("sfx") and current.sfx != "":
		AudioManager.play_sfx(current.sfx)


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

#func show_time_up_dialogue():
	## Define the dialogue lines for running out of time
	## You can have one or more characters speak
	#current_dialogue = [
		#{"name": "Buddy", "text": "Hey, You Good?"},
		#{"name": "Buddy", "text": "Come on bud, Stay Alert!"}
		# Or just one speaker:
		# {"name": "Teacher", "text": "Time's up! You need to answer faster."}
	#]

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
		#show_time_up_dialogue()
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

	# Wait for dialogue to finish, if any
	await _wait_for_dialogue_finish()

	total_problems += 1
	score_label.text = str(score) + "/" + str(total_problems)

	if current_hp <= 0:
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
	if current_hp <= 0:
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

	# Randomly decide on the type of problem
	var max_operand = 10  # Adjust the difficulty as needed.
	
	# Randomly decide the operation type (addition, subtraction, multiplication, etc.)
	var operation_type = randi() % 6  # We have 6 operation types now (addition, subtraction, multiplication, division, exponentiation, PEMDAS)

	var num1 = 0
	var num2 = 0

	match operation_type:
		0: # Addition
			num1 = randi() % max_operand + 1
			num2 = randi() % max_operand + 1
			current_answer = num1 + num2
			problem_label.text = str(num1) + " + " + str(num2) + " = ?"

		1: # Subtraction (ensure no negative results)
			num1 = randi() % max_operand + 1
			num2 = randi() % max_operand + 1
			# Ensure num1 is greater than num2 to prevent negative results
			if num2 > num1:
				var temp = num1
				num1 = num2
				num2 = temp
			current_answer = num1 - num2
			problem_label.text = str(num1) + " - " + str(num2) + " = ?"

		2: # Multiplication
			num1 = randi() % max_operand + 1
			num2 = randi() % max_operand + 1
			current_answer = num1 * num2
			problem_label.text = str(num1) + " x " + str(num2) + " = ?"

		3: # Division (ensure whole number result)
			var quotient = randi() % max_operand + 1
			num2 = randi() % max_operand + 1
			num1 = quotient * num2  # Ensure it's divisible without a remainder
			current_answer = quotient
			problem_label.text = str(num1) + " ÷ " + str(num2) + " = ?"

		4: # Exponentiation
			num1 = randi() % 5 + 1  # Base (1 to 5)
			num2 = randi() % 3 + 2  # Exponent (2 to 4)
			current_answer = pow(num1, num2)
			problem_label.text = str(num1) + " ^ " + str(num2) + " = ?"

		5: # PEMDAS (Combine operations randomly)
			# Create random math expression based on PEMDAS rules
			var a = randi() % max_operand + 1
			var b = randi() % max_operand + 1
			var c = randi() % max_operand + 1
			var pem_type = randi() % 3  # Decide on the PEMDAS structure (could be addition, multiplication, etc.)

			if pem_type == 0:
				# Example: (a + b) × c
				current_answer = (a + b) * c
				problem_label.text = "(" + str(a) + " + " + str(b) + ") × " + str(c) + " = ?"
			elif pem_type == 1:
				# Example: (a × b) - c
				if a * b >= c:
					current_answer = (a * b) - c
					problem_label.text = "(" + str(a) + " x " + str(b) + ") - " + str(c) + " = ?"
				else:
					# Make sure it doesn't generate a negative result
					current_answer = (a + c) - b
					problem_label.text = "(" + str(a + c) + " - " + str(b) + ") = ?"
			else:
				# Example: a + b ÷ c
				var divisor = randi() % max_operand + 1
				var dividend = divisor * (a + b)  # Ensure clean division
				current_answer = dividend / divisor
				problem_label.text = str(dividend) + " ÷ " + str(divisor) + " + " + str(b) + " - " + str(a) + " = ?"
				current_answer += b - a

	# Ensure that everything is ready to go for the user
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
			#if current_hp <= 3 && current_hp > 0:
				#show_feedback_dialogue([
					#{"name": "Buddy", "text": "Be careful! You Ok?"},
					#{"name": "Teacher", "text": "No Worries, I'm Alright"}
				#])

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
		score_label.text = str(score)

		if current_hp <= 0:
			await get_tree().create_timer(0.3).timeout
			end_game()
		else:
			# Wait for dialogue to finish, if any
			await _wait_for_dialogue_finish()
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
	current_dialogue = [
		{"name": "Buddy", "text": "Phew... That was intense!"},
		{"name": "Teacher", "text": "You did great. Let's check your final score."},
		{"name": "", "text": "Your final score was: " + str(score) + " correct answers!"}
	]

	dialogue_active = true
	dialogue_index = 0
	dialogue_animator.play("dialogue_show")
	display_dialogue()

func end_game() -> void:
	timer_active = false
	var player_won = false # There is no "win", only survival

	GameData.set_results_data({
		"player_score": score,
		"max_score": total_problems,
		"player_won": player_won,
		"current_stage": current_stage_path,
		"next_stage": next_stage_path if player_won else "",
		"remaining_hp": current_hp,
		"max_hp": max_hp,
		"is_endless": true  # NEW
	})

	# Show the end stage dialogue
	show_end_stage_dialogue()

	# Wait for the dialogue to finish
	await _wait_for_dialogue_finish()
	
	PlayerData.save_endless_score(score)
	
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
	AudioManager.background_music_player.volume_db = -80 # Mute (almost silent)
	var video_player = VideoStreamPlayer.new()
	add_child(video_player)
	video_player.stream = load(video_path)
	video_player.play()
	video_player.finished.connect(_on_video_finished.bind(video_player))
#
func _on_video_finished(video_player):
	AudioManager.background_music_player.volume_db = 0 # Restore to 0 dB (normal volume)
	video_player.queue_free() # Remove video player
	dialogue_index += 1 # Advance dialogue
	display_dialogue() # Resume dialogue
	
