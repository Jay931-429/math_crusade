extends Node2D
# note! This is for placeholder for now!

# The map container that will be dragged
@onready var map_container = $MapContainer
@onready var viewport_size = get_viewport_rect().size

# Map dimensions
var map_width: float = 618.374
var map_height: float = 1097.75

# Variables for tracking touch/drag input
var touching: bool = false
var drag_start_position: Vector2 = Vector2.ZERO
var original_position: Vector2 = Vector2.ZERO

# Boundaries for the map dragging (will be calculated in _ready)
var min_position: Vector2
var max_position: Vector2

# Zoom variables (optional)
var current_scale: float = 1.0
var min_scale: float = 0.5
var max_scale: float = 2.0
var zoom_speed: float = 0.1

func _ready() -> void:
	# Store the original position of the map container
	original_position = map_container.position
	
	# Calculate the boundaries based on the map and screen size
	calculate_boundaries()
	
	# Load game progress
	GameData.load_game()
	
	# Update all stage buttons
	update_stage_buttons()
	
# Add this variable to your class
var boundary_multiplier: float = 1.2  # Adjust this value to increase boundaries

func calculate_boundaries() -> void:
	# Get the effective map size (considering current scale)
	var effective_map_width = map_width * map_container.scale.x
	var effective_map_height = map_height * map_container.scale.y
	
	# Calculate how much the viewport can "see"
	var half_viewport_size = viewport_size * 0.5
	
	# Ensure the boundaries cover the entire map plus additional movement space
	min_position = Vector2(
		-effective_map_width + half_viewport_size.x,
		-effective_map_height + half_viewport_size.y
	)
	max_position = Vector2(
		effective_map_width - half_viewport_size.x,
		effective_map_height - half_viewport_size.y
	)

	print("Updated Map Boundaries: ", min_position, " to ", max_position)

func _input(event: InputEvent) -> void:
	# Handle touch input for dragging
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch started
			touching = true
			drag_start_position = event.position
			original_position = map_container.position
		else:
			# Touch ended
			touching = false
	
	# Handle drag motion
	elif event is InputEventScreenDrag and touching:
		# Calculate the drag distance
		var drag_distance = event.position - drag_start_position
		
		# Move the map container (note the negative drag_distance to make map move in the direction of the finger)
		var new_position = original_position + drag_distance
		
		# Clamp position within boundaries
		new_position.x = clamp(new_position.x, min_position.x, max_position.x)
		new_position.y = clamp(new_position.y, min_position.y, max_position.y)
		
		map_container.position = new_position
	
	# Handle pinch-to-zoom (optional)
	elif event is InputEventMagnifyGesture:
		# Calculate new scale based on magnify gesture
		var new_scale = current_scale * event.factor
		
		# Clamp scale within bounds
		new_scale = clamp(new_scale, min_scale, max_scale)
		
		# Apply new scale
		map_container.scale = Vector2(new_scale, new_scale)
		current_scale = new_scale
		
		# Recalculate boundaries after scaling
		calculate_boundaries()

# Add this function to handle stage selection
func _on_stage_button_pressed(stage_name: String) -> void:
	# Load the selected stage
	get_tree().change_scene_to_file("res://test_stage_PEMDAS.tscn")
func _on_stage_button_1_pressed() -> void:
	get_tree().change_scene_to_file("res://test_stage_PEMDAS.tscn")
	
func update_stage_buttons() -> void:
	# Find all StageButton nodes
	for button in map_container.find_children("*", "TextureButton", true):
		if button.has_method("update_appearance"):
			# Update each button's state
			var stage_name = button.stage_name
			button.stage_unlocked = GameData.is_stage_unlocked(stage_name)
			button.stage_completed = GameData.is_stage_completed(stage_name)
			button.update_appearance()
