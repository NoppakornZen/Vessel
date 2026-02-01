extends CharacterBody2D

const SPEED = 130.0
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $ProgressBar 
@onready var anim_player = $AnimationPlayer 
@onready var sword_area = $ZayryuHitbox

var last_dir = "Down"
var last_flip = false 
var has_zayryu = false 
var can_attack = true
var is_dead = false # ตัวแปรสถานะตาย
var is_attacking = false # ตัวแปรเพื่อเช็คว่ากำลังฟันอยู่ไหม
var knockback_velocity = Vector2.ZERO

var max_hp = 100
var current_hp = 100 

func _ready():
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	health_bar.visible = false 
	# ตั้งค่า SwordArea ให้ตรวจจับตลอดเวลา
	$ZayryuHitbox.monitoring = true

func _physics_process(delta):
	if is_dead: return

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# ความเร็วให้เวลาเดินอยู่เเล้วยังตีได้อยู่
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)

	# 2. จัดการเรื่อง Animation
	if is_attacking:
		# ถ้ากำลังฟัน ให้ปล่อยให้แอนิเมชันฟันเล่นจนจบ
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
	if not can_attack or is_dead: return
	
	is_attacking = true
	can_attack = false
	$AttackTimer.start()
	
	# ปิดการตรวจจับไว้
	sword_area.monitoring = false 
	
	var attack_anim = "Sword_Attack_" + last_dir 
	sprite.play(attack_anim)
	sprite.flip_h = last_flip
	
	# รอจังหวะให้ดาบเหวี่ยง
	await get_tree().create_timer(0.1).timeout
	sword_area.monitoring = true # เปิดให้ดาบฟันโดนได้จริง
	
	# สั่งสั่นกล้องให้ดูมีน้ำหนัก สะใจจัดดด
	$Camera2D.apply_shake(5.0) #สำคัญ!!!! ทำให้กล้องสั่นนน ปรับความเเรงเบา

func _on_attack_timer_timeout():
	can_attack = true

func take_damage(amount: int, knockback_force: Vector2):
	if is_dead: return
	
	current_hp -= amount
	health_bar.value = current_hp
	knockback_velocity = knockback_force
	
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
	if sprite.animation.begins_with("Sword_Attack"):
		is_attacking = false
		sword_area.monitoring = false # ดาบหาย เดินชนเเล้วเลือดไม่ลด

func change_to_sword_mode():
	
	if anim_player.has_animation("blink_effect"):
		anim_player.play("blink_effect")
	
	await get_tree().create_timer(1.0).timeout
	
	has_zayryu = true
	health_bar.visible = true # โชว์หลอดเลือดเวลา เราเก็บดาบ
	print("Zon has obtained Zayryu!")
	
