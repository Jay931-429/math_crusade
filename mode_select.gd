extends Node2D

@onready var endless_score_label = $EndlessScoreLabel
@onready var endless_button = $CanvasLayer/Mode_Select_UI/custom_stage
@onready var endlabel = $endLabel



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioManager.change_music("menu")
	endless_score_label.text = str(PlayerData.endless_high_score)
	
	if PlayerData.endless_mode_unlocked:
		endless_button.disabled = false
		endless_score_label.visible = true
		#endless_lock_icon.visible = false
		endless_score_label.text = str(PlayerData.endless_high_score)
		endlabel.visible = true
	else:
		endless_button.disabled = true
		endless_score_label.visible = false
		#endless_lock_icon.visible = true
		endlabel.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

# When Presed, the user returns to main menu
func _on_back_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

# When pressed, the user is sent to the opening scene or the opening stage of the game
# For now,it just lead to a test stage.
func _on_campaign_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/campaign_map_container.tscn")


func _on_stages_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/f_boss.tscn")


func _on_tutorial_pressed() -> void:
	pass
	get_tree().change_scene_to_file("res://tutorial_select.tscn")


func _on_custom_stage_pressed() -> void:
	get_tree().change_scene_to_file("res://campaign stages/endless.tscn")
