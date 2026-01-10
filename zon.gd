extends CharacterBody2D

const SPEED = 130.0
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $ProgressBar 
# แก้ไข Path ตรงนี้ให้ตรงกับที่ย้ายไปใน CanvasLayer
@onready var blink_overlay = $CanvasLayer/BlinkOverlay 
@onready var anim_player = $AnimationPlayer 

var last_dir = "Down"
var last_flip = false 
var has_zayryu = false 

# --- ระบบสถานะ (Stats) ---
var max_hp = 100
var current_hp = 100
var max_stamina = 100
var current_stamina = 100
var stamina_regen_rate = 10 
var health = 100 

func _ready():
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	health_bar.visible = false 
	# ตรวจสอบว่ามี blink_overlay ก่อนใช้งานเพื่อป้องกัน Error
	if blink_overlay:
		blink_overlay.modulate.a = 0 

func _physics_process(delta):
	if current_stamina < max_stamina:
		current_stamina += stamina_regen_rate * delta

	# ระบบรับดาบเมื่อกด Space Bar
	if Input.is_action_just_pressed("ui_accept") and not has_zayryu:
		change_to_sword_mode()

	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		_play_run_animation(direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		_play_idle_animation()

	move_and_slide()

# ฟังก์ชันเปลี่ยนโหมดพร้อม Cooldown 1 วินาที
func change_to_sword_mode():
	# 1. เริ่มเล่นแอนิเมชันกะพริบตา (2 วินาทีตามที่คุณตั้งไว้)
	if anim_player.has_animation("blink_effect"):
		anim_player.play("blink_effect")
	
	# 2. ใส่ Cooldown 1 วินาที (รอให้จอดำสนิทที่สุดที่กลางแอนิเมชัน)
	await get_tree().create_timer(1.0).timeout
	
	# 3. เปลี่ยนสถานะเป็นถือดาบ Zayryu
	has_zayryu = true
	health_bar.visible = true 
	print("Zon has obtained Zayryu during 1s cooldown!")

# --- ระบบแอนิเมชันเหมือนเดิม ---
func _play_run_animation(direction):
	if abs(direction.x) > abs(direction.y):
		sprite.play("Sword_Run_Side" if has_zayryu else "Run_Side")
		last_flip = direction.x > 0 
		sprite.flip_h = last_flip
		last_dir = "Side"
	else:
		sprite.flip_h = false
		if direction.y < 0:
			sprite.play("Sword_Run_Up" if has_zayryu else "Run_Up")
			last_dir = "Up"
		else:
			sprite.play("Sword_Run_Down" if has_zayryu else "Run_Down")
			last_dir = "Down"

func _play_idle_animation():
	if last_dir == "Side":
		sprite.play("Sword_Idle_Side" if has_zayryu else "Idle_Side")
		sprite.flip_h = last_flip 
	elif last_dir == "Up":
		sprite.play("Sword_Idle_Up" if has_zayryu else "Idle_Up")
	else:
		sprite.play("Sword_Idle_Down" if has_zayryu else "Idle_Down")
		
func take_damage(amount):
	health -= amount
	print("Zon Health: ", health) # ดูเลือดลดในแถบ Output
	if health <= 0:
		print("เกมโอเวอร์... Zon พ่ายแพ้")
