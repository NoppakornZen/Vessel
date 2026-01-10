extends CharacterBody2D

const SPEED = 130.0
@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $ProgressBar 
@onready var blink_overlay = $CanvasLayer/BlinkOverlay 
@onready var anim_player = $AnimationPlayer 

var last_dir = "Down"
var last_flip = false 
var has_zayryu = false 

# --- ระบบสถานะ (Stats) ---
var max_hp = 100
var current_hp = 100 # ใช้ตัวแปรนี้เป็นหลักในการคำนวณเลือด
var max_stamina = 100
var current_stamina = 100
var stamina_regen_rate = 10 

func _ready():
	# ตั้งค่าเริ่มต้นให้หลอดเลือด
	health_bar.max_value = max_hp
	health_bar.value = current_hp
	health_bar.visible = false 
	
	if blink_overlay:
		blink_overlay.modulate.a = 0 

func _physics_process(delta):
	# ระบบฟื้นฟู Stamina
	if current_stamina < max_stamina:
		current_stamina += stamina_regen_rate * delta

	# การเคลื่อนที่
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		_play_run_animation(direction)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		_play_idle_animation()

	move_and_slide()

# ฟังก์ชันเปลี่ยนโหมด (เรียกใช้งานจากดาบ Zayryu)
func change_to_sword_mode():
	if anim_player.has_animation("blink_effect"):
		anim_player.play("blink_effect")
	
	await get_tree().create_timer(1.0).timeout
	
	has_zayryu = true
	health_bar.visible = true # โชว์หลอดเลือดเมื่อได้ดาบ
	print("Zon has obtained Zayryu!")

# --- ระบบรับความเสียหาย (อัปเดตใหม่) ---
func take_damage(amount):
	current_hp -= amount
	# ป้องกันไม่ให้เลือดติดลบ
	current_hp = clamp(current_hp, 0, max_hp)
	
	# อัปเดตค่าไปยังหลอดเลือดบนหน้าจอทันที
	health_bar.value = current_hp
	
	print("Zon Health: ", current_hp) 
	
	if current_hp <= 0:
		die()

func die():
	# จุดเริ่มต้นของฉากจบที่เศร้าและมืดมน
	print("เกมโอเวอร์... Zon พ่ายแพ้")
	# หยุดการควบคุม
	set_physics_process(false) 
	# ตรงนี้สามารถใส่โค้ดเปลี่ยนฉากไปหน้า Game Over ได้ครับ

# --- ระบบแอนิเมชัน (คงเดิม) ---
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
