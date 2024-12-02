extends CharacterBody2D

const SPEED = 120
const DASH_SPEED = 300
const DASH_TIME = 0.2

var current_dir = "none"
var is_dashing = false
var dash_timer = 0.0

var is_attacking = false  # Variabel untuk memeriksa apakah sedang menyerang

var enemy_inattack_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

@onready var walk = $WalkSFX

func _ready():
	$AnimatedSprite2D.play("Idle depan")

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
		self.queue_free()

func player_movement(_delta):
	if Input.is_action_just_pressed("Dash") and not is_dashing:
		start_dash()
	elif not is_dashing:
		if Input.is_action_pressed("Kanan") or Input.is_action_just_pressed("Kanan"):
			current_dir = "right"
			play_anim(1)
			velocity.x = SPEED
			velocity.y = 0
			if !walk.playing:
				walk.play()
		elif Input.is_action_pressed("Kiri"):
			current_dir = "left"
			play_anim(1)
			velocity.x = -SPEED
			velocity.y = 0
			if !walk.playing:
				walk.play()
		elif Input.is_action_pressed("Belakang"):
			current_dir = "down"
			play_anim(1)
			velocity.y = SPEED
			velocity.x = 0
			if !walk.playing:
				walk.play()
		elif Input.is_action_pressed("Depan"):
			current_dir = "up"
			play_anim(1)
			velocity.y = -SPEED
			velocity.x = 0
			if !walk.playing:
				walk.play()
		elif Input.is_action_just_pressed("attack") and not is_attacking:  # Menambahkan kondisi tidak sedang menyerang
			start_attack()  # Mulai animasi serangan

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
		"left":
			$AnimatedSprite2D.play("Attack kiri")
		"down":
			$AnimatedSprite2D.play("Attack depan")
		"up":
			$AnimatedSprite2D.play("Attack belakang")
	# Menghubungkan sinyal animation_finished dengan metode yang benar
	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_attack_animation_finished"))

func _on_attack_animation_finished(anim_name):
	if anim_name.begins_with("attack"):  # Jdika animasi yang selesai adalah animasi attack
		is_attacking = false  # Setel status attacking kembali menjadi false
		
		# Pindah ke animasi idle setelah serangan
		play_anim(0)  # Ini akan memutar animasi idle berdasarkan arah karakter yang terakhir
		
		# Melepaskan koneksi sinyal yang sudah tidak diperlukan lagi
		$AnimatedSprite2D.disconnect("animation_finished", Callable(self, "_on_attack_animation_finished"))

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
		self.queue_free()
