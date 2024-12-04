extends Control
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio_stream_player.play() # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_bg_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu_Scenes/level_select.tscn")

func _on_exite_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menu_Scenes/HomeMenu.tscn")
