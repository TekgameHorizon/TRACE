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

@onready var healthbar = $CanvasLayer/HealthBar

var SPEED = 45
var player_chase = false
var player = null
var is_attacking = false
var ATTACK_DISTANCE = 40 # Jarak untuk memasuki serangan
var START_DISTANCE = 24  # Jarak berhenti mengejar player
var start_position = Vector2()  # Posisi awal enemy
var attack_timer = 0.0  # Timer untuk menghitung detik saat menyerang
var enemy_health = 250
var current_dir = "none"

func _ready():
	# Simpan posisi awal saat game dimulai
	start_position = position
	$AnimatedSprite2D.play("Idle depan")
	healthbar.init_health(enemy_health)
	$CanvasLayer/HealthBar.visible = false
	$CanvasLayer/Label.visible = false

func _physics_process(delta):
	if player_chase:
		# Menghitung jarak antara enemy dan player
		var distance_to_player = position.distance_to(player.position)
		
		# Jika jarak lebih besar dari START_DISTANCE, enemy terus mengejar
		if distance_to_player > START_DISTANCE:
			position += (player.position - position).normalized() * SPEED * delta
			$AnimatedSprite2D.play("Move kanan")
			$AnimatedSprite2D.flip_h = (player.position.x - position.x) < 0
			# Debug: Periksa apakah sedang mengejar

		# Jika sudah berada dalam jarak serangan
		elif distance_to_player <= ATTACK_DISTANCE:
			$AnimatedSprite2D.play("Attack kanan")

			# Mengurangi darah pemain setiap detik
			if !is_attacking:
				attack_timer += delta
				if attack_timer >= 1.0:  # Setiap detik
					attack_timer = 0  # Reset timer
					if player.has_method("decrease_health"):  # Pastikan player memiliki metode decrease_health
						player.decrease_health(1)  # Mengurangi darah pemain 5 per detik
		
		else:
			# Jika sudah cukup dekat dengan player, berhenti mengejar
			$AnimatedSprite2D.play("Idle depan")
			
	elif not is_attacking:
		# Enemy kembali ke posisi awal
		var distance_to_start = position.distance_to(start_position)
		if distance_to_start > 5:
			position += (start_position - position).normalized() * SPEED * delta
			$AnimatedSprite2D.play("Move kanan")
			
			
			# Flip sprite direction saat kembali
			$AnimatedSprite2D.flip_h = (start_position.x - position.x) < 0

			# Debug: Periksa apakah sedang kembali ke posisi awal
		else:
			# Enemy sudah di posisi awal
			position = start_position  # Pastikan posisi tepat di start_position
			$AnimatedSprite2D.play("Idle depan")
	else:
		# Debug: Periksa idle state
		print("Enemy idle...")

# Called when the hitbox detects a collision
func _on_hitbox_area_entered(body: Node2D) -> void:
	if body == player:
		is_attacking = true
		$AnimatedSprite2D.play("attack")
		
		# Tunggu animasi selesai
		await $AnimatedSprite2D.animation_finished
		is_attacking = false
		# Setelah serangan selesai, enemy tidak bergerak
		player_chase = false  # Stop chasing player

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	#$if !walk.playing:
			#walk.play()

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	#walk.stop()
	
func enemy():
	pass

func enemy_take_damage(amount: int):
	if not $CanvasLayer/HealthBar.visible:
		$CanvasLayer/HealthBar.visible = true
	
	if not $CanvasLayer/Label.visible:
		$CanvasLayer/Label.visible = true
	
	enemy_health -= amount
	print("Enemy health: " + str(enemy_health))
	if enemy_health <= 0:
		enemy_health = 0
		print("Enemy has been killed")
		queue_free()
		get_tree().change_scene_to_file("res://Scenes/Level_Scenes/level_2.tscn")  # Hancurkan enemy jika darah habis
		
	healthbar.health = enemy_health
