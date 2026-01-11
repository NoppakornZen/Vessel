extends CharacterBody2D

const SPEED = 130.0
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $ProgressBar 
@onready var anim_player = $AnimationPlayer 
@onready var sword_area = $SwordArea

var last_dir = "Down"
var last_flip = false 
var has_zayryu = false 
var can_attack = true
var is_dead = false # เพิ่มตัวแปรเช็คสถานะตาย
var is_attacking = false # เพิ่มตัวแปรเพื่อเช็คว่ากำลังฟันอยู่หรือไม่

var max_hp = 100
var current_hp = 100 

func _ready():
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	health_bar.visible = false 
	# ตั้งค่า SwordArea ให้ตรวจจับตลอดเวลา
	sword_area.monitoring = true 

func _physics_process(delta):
	if is_dead: return

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# 1. จัดการเรื่องความเร็ว (Velocity) ตลอดเวลา เพื่อให้เดินได้แม้จะฟันอยู่
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	# 2. จัดการเรื่อง Animation
	if is_attacking:
		# ถ้ากำลังฟัน ให้ปล่อยให้แอนิเมชันฟันเล่นจนจบ (ไม่ต้องสั่ง play ซ้ำ)
		pass 
	elif direction != Vector2.ZERO:
		# ถ้าเดินและไม่ได้ฟัน ให้เล่นท่าเดิน
		_play_run_animation(direction)
	else:
		# ถ้ายืนนิ่งและไม่ได้ฟัน ให้เล่นท่า Idle
		_play_idle_animation()

	move_and_slide()

func _input(event):
	if is_dead: return
	# ฟันได้เลยไม่ต้องรอเจอศัตรู แค่มีดาบและคูลดาวน์เสร็จ
	if event.is_action_pressed("attack") and can_attack and has_zayryu:
		perform_attack()

func perform_attack():
	is_attacking = true 
	$AttackTimer.start()
	
	var attack_anim = "Sword_Attack_" + last_dir 
	sprite.play(attack_anim)
	sprite.flip_h = last_flip
	
	# ส่วนของการทำ Damage
	var targets = sword_area.get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("mobs") and body.has_method("take_damage"):
			var knockback_direction = (body.global_position - global_position).normalized()
			body.take_damage(knockback_direction * 400.0)

func _on_attack_timer_timeout():
	can_attack = true

func take_damage(amount):
	if is_dead: return
	current_hp = clamp(current_hp - amount, 0, max_hp)
	health_bar.value = current_hp
	if current_hp <= 0:
		die()

func die():
	is_dead = true
	print("เกมโอเวอร์... Zon พ่ายแพ้") 
	velocity = Vector2.ZERO
	# เล่นแอนิเมชันตาย (ถ้ามี) หรือหยุดที่เฟรมแรกของท่า Idle
	_play_idle_animation()
	sprite.stop() # หยุดการ Loop ของแอนิเมชันทุกอย่าง

# --- แอนิเมชันคงเดิม ---
func _play_run_animation(direction):
	if abs(direction.x) > abs(direction.y):
		# เดินซ้าย-ขวา
		last_dir = "Side"
		last_flip = direction.x > 0 
		sprite.flip_h = last_flip
		sprite.play("Sword_Run_Side" if has_zayryu else "Run_Side")
	else:
		# เดินบน-ล่าง
		sprite.flip_h = false
		if direction.y < 0:
			last_dir = "Up"
			sprite.play("Sword_Run_Up" if has_zayryu else "Run_Up")
		else:
			last_dir = "Down"
			sprite.play("Sword_Run_Down" if has_zayryu else "Run_Down")

func _play_idle_animation():
	if last_dir == "Side":
		sprite.play("Sword_Idle_Side" if has_zayryu else "Idle_Side")
		sprite.flip_h = last_flip 
	elif last_dir == "Up":
		sprite.play("Sword_Idle_Up" if has_zayryu else "Idle_Up")
	else:
		sprite.play("Sword_Idle_Down" if has_zayryu else "Idle_Down")

# ฟังก์ชันนี้จะทำงานอัตโนมัติเมื่อแอนิเมชันเล่นจนจบเฟรมสุดท้าย
func _on_animated_sprite_2d_animation_finished():
	# เมื่อท่าฟันจบ ให้ปลดล็อคสถานะทันที
	if sprite.animation.begins_with("Sword_Attack"):
		is_attacking = false

func change_to_sword_mode():
	# สั่งให้ AnimationPlayer เล่นท่ากระพริบตาที่เราตั้งไว้
	if anim_player.has_animation("blink_effect"):
		anim_player.play("blink_effect")
	
	# รอ 1 วินาทีให้เอฟเฟกต์เล่นจบก่อนค่อยเปลี่ยนโหมด
	await get_tree().create_timer(1.0).timeout
	
	has_zayryu = true
	health_bar.visible = true # โชว์หลอดเลือดเมื่อได้ดาบ Zayryu
	print("Zon has obtained Zayryu!")
	
