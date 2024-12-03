extends CharacterBody2D
@onready var healthbar = $HealthBar

var SPEED = 45
var player_chase = false
var player = null
var is_attacking = false
var ATTACK_DISTANCE = 100  # Jarak untuk memasuki serangan
var START_DISTANCE = 60    # Jarak berhenti mengejar player
var start_position = Vector2()  # Posisi awal enemy
var attack_timer = 0.0  # Timer untuk menghitung detik saat menyerang
var enemy_health = 100

var bullet_speed = 80
@onready var bullet = $tembakan  # Node AnimatedSprite2D untuk peluru

func _ready():
	# Simpan posisi awal saat game dimulai
	start_position = position
	$AnimatedSprite2D.play("Idle depan")
	bullet.visible = false  # Pastikan peluru disembunyikan saat mulai
	healthbar.init_health(enemy_health)

func _physics_process(delta):
	if player_chase:
		var distance_to_player = position.distance_to(player.position)
		
		if distance_to_player > START_DISTANCE:
			position += (player.position - position).normalized() * SPEED * delta
			$AnimatedSprite2D.play("Move kanan")
			$AnimatedSprite2D.flip_h = (player.position.x - position.x) < 0
		elif distance_to_player <= ATTACK_DISTANCE:
			spawn_bullet()
		else:
			$AnimatedSprite2D.play("Idle depan")
	elif not is_attacking:
		var distance_to_start = position.distance_to(start_position)
		if distance_to_start > 5:
			position += (start_position - position).normalized() * SPEED * delta
			$AnimatedSprite2D.play("Move kanan")
			$AnimatedSprite2D.flip_h = (start_position.x - position.x) < 0
		else:
			position = start_position
			$AnimatedSprite2D.play("Idle depan")
	else:
		print("Enemy idle...")

# Spawn tembakan di posisi enemy dan gerakkan ke arah player
func spawn_bullet():
	if not bullet.visible:
		bullet.global_position = global_position
		bullet.visible = true
		$AnimatedSprite2D.play("Attack kanan")

# Gerakkan peluru ke arah player
func _process(delta):
	if bullet.visible:
		if player:
			bullet.global_position += (player.global_position - bullet.global_position).normalized() * bullet_speed * delta
			
			# Jika peluru mengenai player
			if bullet.global_position.distance_to(player.global_position) < 10:
				bullet.visible = false  # Hilangkan peluru
				if player.has_method("decrease_health"):
					player.decrease_health(3)

# Called when the hitbox detects a collision
func _on_hitbox_area_entered(body: Node2D) -> void:
	if body == player:
		is_attacking = true
		$AnimatedSprite2D.play("Attack kanan")
		await $AnimatedSprite2D.animation_finished
		is_attacking = false
		player_chase = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	player = null
	player_chase = false
	
func enemy_take_damage(amount: int):
	enemy_health -= amount
	print("Enemy health: " + str(enemy_health))
	if enemy_health <= 0:
		enemy_health = 0
		print("Enemy has been killed")
		queue_free()  # Hancurkan enemy jika darah habis
		
	healthbar.health = enemy_health
