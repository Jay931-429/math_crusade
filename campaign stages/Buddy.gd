extends AnimatedSprite2D

@export var player: Node2D # Reference to the player node
@export var animation_delay: float = 0.1 # Delay in seconds

func _ready() -> void:
	if not player:
		printerr("Buddy: Player reference not set!")

func play_delayed_animation(animation_name: String) -> void:
	# Use a Timer or create_tween to delay the animation
	await get_tree().create_timer(animation_delay).timeout
	play(animation_name)

func follow_player_animation(player_animation_name: String) -> void:
	match player_animation_name:
		"Run":
			play_delayed_animation("Run")
		"Attack":
			play_delayed_animation("Attack")
		"Idle":
			play("Idle") # No delay for Idle
		"Hit":
			play_delayed_animation("Hit")
		_:
			pass # Handle other animations if needed
