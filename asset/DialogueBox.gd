# DialogueBox.gd
extends CanvasLayer

# Signal emitted when all dialogue lines have been shown
signal dialogue_finished

# === UI Nodes ===
@onready var dialogue_panel: PanelContainer = $DialoguePanel
@onready var dialogue_label: RichTextLabel = $DialoguePanel/DialogueLabel
@onready var advance_indicator: Label = $DialoguePanel/AdvanceIndicator # Adjust path if needed

# === Dialogue State ===
var dialogue_lines: Array[String] = []
var current_line_index: int = -1
var is_active: bool = false # Is the dialogue box currently showing lines?

# === Typewriter Effect (Optional) ===
@export var characters_per_second: float = 30.0 # Adjust speed as desired
var display_timer: float = 0.0
var is_line_displaying: bool = false # True while text is appearing via typewriter

# --- Initialization ---
func _ready() -> void:
	# Start hidden
	dialogue_panel.visible = false
	advance_indicator.visible = false

# --- Input Handling ---
func _unhandled_input(event: InputEvent) -> void:
	# Only process input if the dialogue box is active
	if not is_active:
		return

	# Check for the action to advance dialogue (e.g., mouse click or Enter/Space key)
	# You might want to use a specific action configured in Input Map like "ui_accept"
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		# Mark the event as handled so other things don't process it (like game input)
		get_viewport().set_input_as_handled()
		_try_advance_dialogue()


# --- Public Methods ---

# Call this from your stage script to begin showing dialogue
func start(lines: Array[String]) -> void:
	if lines.is_empty():
		printerr("DialogueBox.start(): No lines provided.")
		return

	dialogue_lines = lines
	current_line_index = -1
	is_active = true
	dialogue_panel.visible = true
	_advance_line() # Display the first line

# --- Internal Logic ---

func _try_advance_dialogue() -> void:
	if is_line_displaying:
		# If line is still typing out, finish it instantly
		dialogue_label.visible_ratio = 1.0
		is_line_displaying = false
		advance_indicator.visible = true # Show indicator now that line is complete
	else:
		# If line is fully displayed, move to the next line
		_advance_line()

func _advance_line() -> void:
	current_line_index += 1
	advance_indicator.visible = false # Hide indicator while preparing next line

	if current_line_index >= dialogue_lines.size():
		# Reached the end of the dialogue
		_finish_dialogue()
	else:
		# Display the next line using the typewriter effect
		dialogue_label.bbcode_text = dialogue_lines[current_line_index]
		dialogue_label.visible_ratio = 0.0 # Reset for typewriter
		display_timer = 0.0
		is_line_displaying = true

func _finish_dialogue() -> void:
	dialogue_panel.visible = false
	is_active = false
	dialogue_lines = []
	current_line_index = -1
	dialogue_finished.emit()

# --- Typewriter Process ---
func _process(delta: float) -> void:
	if is_line_displaying and dialogue_label.visible_ratio < 1.0:
		# Calculate how many characters to reveal this frame
		display_timer += delta * characters_per_second
		var total_chars = dialogue_label.get_total_character_count()
		if total_chars > 0: # Avoid division by zero if text is empty
			dialogue_label.visible_ratio = display_timer / float(total_chars)
		else:
			dialogue_label.visible_ratio = 1.0 # Mark as complete if text was empty

		# Check if finished displaying
		if dialogue_label.visible_ratio >= 1.0:
			is_line_displaying = false
			advance_indicator.visible = true # Show indicator
