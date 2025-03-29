extends Node

# Placed on Autoload tab
# "Global" Script
# Reference resolution (design resolution)
const REFERENCE_WIDTH := 1080  # Common mobile width
const REFERENCE_HEIGHT := 1920 # Common mobile height

# Scaling factors
var scale_factor: float = 1.0
var viewport_width: float
var viewport_height: float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect to window size changed signal
	get_tree().root.size_changed.connect(_on_screen_resized)
	# Initial calculation
	_on_screen_resized()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_screen_resized() -> void:
	viewport_width = get_viewport().get_visible_rect().size.x
	viewport_height = get_viewport().get_visible_rect().size.y

		# Calculate scaling factors for both dimensions
	var scale_x = viewport_width / REFERENCE_WIDTH
	var scale_y = viewport_height / REFERENCE_HEIGHT

	# Use the smaller scaling factor to ensure everything fits
	scale_factor = min(scale_x, scale_y)

	# Apply scaling to all registered nodes
	adjust_game_elements()

func adjust_game_elements() -> void:
	# Find the root node of your main game scene
	var root = get_tree().current_scene
	if root:
		_adjust_node_recursive(root)

func _adjust_node_recursive(node: Node) -> void:
	# Adjust Control nodes
	if node is Control:
		_adjust_control_node(node)

	# Adjust Sprite2D nodes
	if node is Sprite2D:
		_adjust_sprite_node(node)

	# Recursively process child nodes
	for child in node.get_children():
		_adjust_node_recursive(child)

func _adjust_control_node(control: Control) -> void:
	# Scale custom minimum size if set
	if control.custom_minimum_size != Vector2.ZERO:
		control.custom_minimum_size = control.custom_minimum_size * scale_factor

	# Scale margins and anchors based on parent size
	var margin_scale = Vector2(viewport_width, viewport_height)
	control.position *= scale_factor

	# If using anchors, adjust anchor offsets
	control.anchor_left *= scale_factor
	control.anchor_right *= scale_factor
	control.anchor_top *= scale_factor
	control.anchor_bottom *= scale_factor

func _adjust_sprite_node(sprite: Sprite2D) -> void:
	# Scale sprite size while maintaining aspect ratio
	sprite.scale = Vector2(scale_factor, scale_factor)
