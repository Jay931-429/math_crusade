extends TextureButton

# Stage properties
@export var stage_name: String = "test_stage"
@export var stage_unlocked: bool = true
@export var stage_completed: bool = false

# Textures for different states
@export var locked_texture: Texture2D
@export var unlocked_texture: Texture2D
@export var completed_texture: Texture2D

# Display elements
@onready var stage_label = $StageLabel
@onready var locked_icon = $LockedIcon

func _ready() -> void:
	# Set up the button appearance based on stage status
	update_appearance()
	
	# Connect the button pressed signal
	connect("pressed", _on_button_pressed)

func update_appearance() -> void:
	if stage_completed:
		# Stage is completed
		texture_normal = completed_texture
		locked_icon.visible = false
		modulate = Color(1, 1, 1, 1)  # Full opacity
	elif stage_unlocked:
		# Stage is unlocked but not completed
		texture_normal = unlocked_texture
		locked_icon.visible = false
		modulate = Color(1, 1, 1, 1)  # Full opacity
	else:
		# Stage is locked
		texture_normal = locked_texture
		locked_icon.visible = true
		modulate = Color(1, 1, 1, 0.7)  # Slightly transparent
	
	# Set the stage name
	stage_label.text = stage_name.capitalize()
	
	# Disable the button if it's locked
	disabled = !stage_unlocked

func _on_button_pressed() -> void:
	if stage_unlocked:
		# Get the parent map and call its stage selection function
		get_parent().get_parent()._on_stage_button_pressed(stage_name)
