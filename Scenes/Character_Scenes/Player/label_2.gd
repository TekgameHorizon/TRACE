extends Label


var score = 0

# Function to update the score
func update_score(new_score):
	score = new_score
	text = "Enemies kill : " + str(score)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass