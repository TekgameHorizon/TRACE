extends CharacterBody2D
@onready var idle_sfx = $SFX/IdleSFX
@onready var move_sfx = $SFX/MoveSFX

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

func _physics_process(delta: float) -> void:
pass

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		idle_sfx.stop()
		move_sfx.play()
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if !idle_sfx.playing:
				idle_sfx.play()

	move_and_slide()
