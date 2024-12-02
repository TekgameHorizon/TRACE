extends CharacterBody2D

const SPEED = 120
const DASH_SPEED = 300
const DASH_TIME = 0.2

var current_dir = "none"
var is_dashing = false
var dash_timer = 0.0
var is_attacking = false
var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

@onready var walk = $WalkSFX
@onready var attack_timer = Timer.new()  # Timer dibuat secara dinamis

func _ready():
	$AnimatedSprite2D.play("Idle depan")
	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))

func _physics_process(delta):
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		if not is_attacking:
			player_movement(delta)
	
	move_and_slide()
	enemy_attack()
	
	if health <= 0:
		player_alive = false
		health = 0
		print("Player has been killed")
		self.queue_free()

func player_movement(_delta):
	if Input.is_action_just_pressed("Dash") and not is_dashing:
		start_dash()
	elif Input.is_action_just_pressed("attack"):
		
		start_attack()
	elif not is_dashing and not is_attacking:  # Pastikan pemain tidak menyerang
		if Input.is_action_pressed("Kanan"):
			current_dir = "right"
			play_anim(1)
			velocity.x = SPEED
			velocity.y = 0
			if not walk.playing:
				walk.play()
		elif Input.is_action_pressed("Kiri"):
			current_dir = "left"
			play_anim(1)
			velocity.x = -SPEED
			velocity.y = 0
			if not walk.playing:
				walk.play()
		elif Input.is_action_pressed("Belakang"):
			current_dir = "down"
			play_anim(1)
			velocity.y = SPEED
			velocity.x = 0
			if not walk.playing:
				walk.play()
		elif Input.is_action_pressed("Depan"):
			current_dir = "up"
			play_anim(1)
			velocity.y = -SPEED
			velocity.x = 0
			if not walk.playing:
				walk.play()
		else:
			play_anim(0)
			velocity.x = 0
			velocity.y = 0
			walk.stop()
	

func start_dash():
	is_dashing = true
	dash_timer = DASH_TIME
	match current_dir:
		"right":
			velocity.x = DASH_SPEED
			velocity.y = 0
		"left":
			velocity.x = -DASH_SPEED
			velocity.y = 0
		"down":
			velocity.x = 0
			velocity.y = DASH_SPEED
		"up":
			velocity.x = 0
			velocity.y = -DASH_SPEED

func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if movement == 1:
			anim.play("Move kanan")
		elif movement == 0:
			anim.play("Idle kanan")
	elif dir == "left":
		anim.flip_h = false
		if movement == 1:
			anim.play("Move kiri")
		elif movement == 0:
			anim.play("Idle kiri")
	elif dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("Move depan")
		elif movement == 0:
			anim.play("Idle depan")
	elif dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("Move belakang")
		elif movement == 0:
			anim.play("Idle belakang")

func start_attack():
	is_attacking = true
	velocity = Vector2.ZERO  # Hentikan gerakan saat menyerang
	print("attack di press")
	
	# Menyesuaikan posisi CollisionShape2D berdasarkan arah serangan
	var hitbox = $HitBox  # Akses CollisionShape2D di dalam HitBox
	
	match current_dir:
		"right":
			$AnimatedSprite2D.play("Attack kanan")
			hitbox.position.x = 7  # Pindahkan CollisionShape2D ke kanan
			print("Hitbox position (right): " + str(hitbox.position))  # Print posisi
		"left":
			$AnimatedSprite2D.play("Attack kiri")
			hitbox.position.x = -7  # Pindahkan CollisionShape2D ke kiri
			print("Hitbox position (left): " + str(hitbox.position))  # Print posisi
		"down":
			$AnimatedSprite2D.play("Attack depan")
			hitbox.position.y = -1  # Pindahkan CollisionShape2D ke bawah
			print("Hitbox position (down): " + str(hitbox.position))  # Print posisi
		"up":
			$AnimatedSprite2D.play("Attack belakang")
			hitbox.position.y = -15  # Pindahkan CollisionShape2D ke atas
			print("Hitbox position (up): " + str(hitbox.position))  # Print posisi
			
	attack_timer.start()
	# Hubungkan sinyal hanya sekali dengan Callabl
	var overlapping_bodies = hitbox.get_overlapping_bodies()  # Get overlapping bodies from Area2D
	for object in overlapping_bodies:
		if object.has_method("enemy"):  # Make sure the object is an enemy
			object.enemy_take_damage(15)

func _on_attack_animation_finished(anim_name: String):
	if anim_name.begins_with("attack"):
		is_attacking = false
		play_anim(0)  # Kembali ke animasi idle
		
		# Lepaskan koneksi sinyal setelah selesai
		$AnimatedSprite2D.disconnect("animation_finished", Callable(self, "_on_attack_animation_finished"))

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false

func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown:
		health -= 5
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print("Player health: " + str(health))

func _on_cool_down_timeout() -> void:
	enemy_attack_cooldown = true

func decrease_health(amount: int):
	health -= amount
	print("Player health: " + str(health))
	if health <= 0:
		player_alive = false
		health = 0
		print("Player has been killed")
		self.queue_free()
		
func _on_attack_timer_timeout() :
	is_attacking = false
	var hitbox = $HitBox/CollisionShape2D
	hitbox.position.y = -8
	hitbox.position.x = 0
