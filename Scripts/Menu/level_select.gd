extends Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://Scenes/Menu_Scenes/HomeMenu.tscn")

func _on_lv_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_Scenes/level_1.tscn")

func _on_lv_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level_Scenes/level_2.tscn")
