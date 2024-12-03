extends CharacterBody2D
@onready var healthbar = $CanvasLayer/HealthBar

const SPEED = 100
const DASH_SPEED = 300
const DASH_TIME = 0.2

var current_dir = "none"
var is_dashing = false
var dash_timer = 0.0

var is_attacking = false # Variabel untuk memeriksa apakah sedang menyerang

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 10
var player_alive = true

@onready var attack_sfx = $SFX/AttackSFX
@onready var walk_sfx = $SFX/WalkSFX

func _ready():
	$AnimatedSprite2D.play("Idle depan")
	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))

	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	healthbar.init_health(health)


func _physics_process(delta):
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	else:
		if not is_attacking:  # Jika tidak sedang menyerang, biarkan pemain bergerak
			player_movement(delta)
		
	move_and_slide()
	
	
	enemy_attack()
	if health <= 0:
		player_alive = false
		health = 0
		print("player has been killed")
		get_tree().change_scene_to_file("res://Scenes/Menu_Scenes/game_over.tscn")

func player_movement(_delta):
	if Input.is_action_just_pressed("Dash") and not is_dashing:
		start_dash()

	elif not is_dashing:

		if Input.is_action_pressed("Kanan") or Input.is_action_just_pressed("Kanan"):
	elif Input.is_action_just_pressed("attack"):
		start_attack()
	elif not is_dashing and not is_attacking:  # Pastikan pemain tidak menyerang
		if Input.is_action_pressed("Kanan"):

			current_dir = "right"
			play_anim(1)
			velocity.x = SPEED
			velocity.y = 0
			if !walk_sfx.playing:
				walk_sfx.play()
		elif Input.is_action_pressed("Kiri"):
			current_dir = "left"
			play_anim(1)
			velocity.x = -SPEED
			velocity.y = 0
			if !walk_sfx.playing:
				walk_sfx.play()
		elif Input.is_action_pressed("Belakang"):
			current_dir = "down"
			play_anim(1)
			velocity.y = SPEED
			velocity.x = 0
			if !walk_sfx.playing:
				walk_sfx.play()
		elif Input.is_action_pressed("Depan"):
			current_dir = "up"
			play_anim(1)
			velocity.y = -SPEED
			velocity.x = 0
			if !walk_sfx.playing:
				walk_sfx.play()
		elif Input.is_action_just_pressed("attack") and not is_attacking:  # Menambahkan kondisi tidak sedang menyerang
			start_attack()  # Mulai animasi serangan

		else:
			play_anim(0)
			velocity.x = 0
			velocity.y = 0
			walk_sfx.stop()

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
			
	if dir == "left":
		anim.flip_h = false
		if movement == 1:
			anim.play("Move kiri")
		elif movement == 0:
			anim.play("Idle kiri")

	if dir == "down":
		anim.flip_h = true
		if movement == 1:
			anim.play("Move depan")
		elif movement == 0:
			anim.play("Idle depan")
	if dir == "up":
		anim.flip_h = true
		if movement == 1:
			anim.play("Move belakang")
		elif movement == 0:
			anim.play("Idle belakang")

func start_attack():

	is_attacking = true  # Menandakan bahwa pemain sedang menyerang
	match current_dir:
		"right":
			$AnimatedSprite2D.play("Attack kanan")
			attack_sfx.play()
		"left":
			$AnimatedSprite2D.play("Attack kiri")
			attack_sfx.play()
		"down":
			$AnimatedSprite2D.play("Attack depan")
			attack_sfx.play()
		"up":
			$AnimatedSprite2D.play("Attack belakang")
			attack_sfx.play()

	# Menghubungkan sinyal animation_finished dengan metode yang benar
	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))

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
			object.enemy_take_damage(20)

func _on_attack_animation_finished(anim_name):
	# Debugging: cek nama animasi yang selesai
	print("Animation finished: " + anim_name)

	# Mengecek apakah animasi yang selesai adalah animasi attack
	if anim_name.begins_with("Attack"):  
		# Debugging: cek status is_attacking sebelum dan sesudah
		print("Before is_attacking:", is_attacking)
		
		# Pastikan hanya mengubah status is_attacking setelah animasi serangan selesai
		is_attacking = false
		print("After is_attacking:", is_attacking)
		
		# Pindah ke animasi idle setelah serangan selesai
		# Pastikan hanya play animasi idle jika tidak sedang bergerak atau menyerang
		if not is_attacking:
			play_anim(0)  # Ini akan memutar animasi idle berdasarkan arah karakter yang terakhir


func player():
	pass

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = true

func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.has_method("enemy"):
		enemy_inattack_range = false
		
func enemy_attack():
	if enemy_inattack_range and enemy_attack_cooldown:
		health -= 5  # Mengurangi darah 5 setiap detik
		enemy_attack_cooldown = false
		$attack_cooldown.start()
		print("Player health: " + str(health))

func _on_cool_down_timeout() -> void:
	enemy_attack_cooldown = true

# Metode untuk mengurangi darah pemain
func decrease_health(amount: int):
	health -= amount
	print("Player health: " + str(health))
	if health <= 0:
		player_alive = false
		health = 0
		print("player has been killed")
		get_tree().change_scene_to_file("res://Scenes/Menu_Scenes/game_over.tscn")
		self.queue_free()
	
	healthbar.health = health

func _on_attack_timer_timeout() :
	is_attacking = false
	var hitbox = $HitBox/CollisionShape2D
	hitbox.position.y = -8
	hitbox.position.x = 0
