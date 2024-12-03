extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	AudioServer.set_bus_volume_db(0, linear_to_db($"Audio Menu/VBoxContainer/Master Slider".value))
	AudioServer.set_bus_volume_db(1, linear_to_db($"Audio Menu/VBoxContainer/Music Slider".value))
	AudioServer.set_bus_volume_db(2, linear_to_db($"Audio Menu/VBoxContainer/SFX Slider".value))
