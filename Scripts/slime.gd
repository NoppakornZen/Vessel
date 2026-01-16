extends CharacterBody2D

var player = null
var chase = false
var can_attack = false
var max_hp = 100 # ตั้งค่าเลือดสูงสุดเป็น 100
var current_hp = 100
var is_dead = false

const SPEED = 50.0
const ATTACK_DAMAGE = 10
const ATTACK_COOLDOWN = 1.0 

@onready var health_bar = $ProgressBar # เพิ่มบรรทัดนี้เพื่อให้สคริปต์รู้จักหลอดเลือด

var attack_timer = 0.0
# --- เพิ่มส่วนประกอบสำหรับแรงผลัก (Knockback) ---
var knockback_velocity = Vector2.ZERO

func _ready():
	add_to_group("mobs") 
	health_bar.max_value = max_hp # ตั้งค่าสูงสุดเป็น 100
	health_bar.value = current_hp # เริ่มต้นที่ 100

func _physics_process(delta):
	# 1. จัดการแรงผลัก (ถ้ามีแรงส่งมา ให้เคลื่อนที่ตามแรงผลักก่อน)
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		# ค่อยๆ ลดแรงผลักลงเหมือนแรงเสียดทาน (0.1 คือความลื่น ปรับเพิ่มได้)
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)
	
	# 2. ระบบ AI เดิมของคุณ
	elif chase and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		
		if can_attack:
			attack_timer += delta
			if attack_timer >= ATTACK_COOLDOWN:
				_perform_attack()
				attack_timer = 0.0 
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

# --- ฟังก์ชันรับความเสียหายจาก Zon (ถูกเรียกใช้โดย zon.gd) ---
func take_damage(amount: int, knockback_force: Vector2):
	if is_dead: return
	
	current_hp -= amount
	health_bar.value = current_hp
	
	# เปลี่ยนจาก velocity เป็น knockback_velocity เพื่อให้ระบบค่อยๆ เบรกทำงาน
	knockback_velocity = knockback_force 
	
	if current_hp <= 0:
		die()

# ฟังก์ชันสั่งโจมตี (คงเดิม)
func _perform_attack():
	if player and player.has_method("take_damage"):
		# คำนวณทิศทางแรงผลักจาก Slime ไปยัง Zon
		var knockback_dir = (player.global_position - global_position).normalized()
		
		# ส่งค่า 2 อย่าง: 1. ดาเมจ (10), 2. แรงผลัก (knockback_dir * แรงที่ต้องการ)
		player.take_damage(ATTACK_DAMAGE, knockback_dir * 300.0) 
		print("Slime: กัด Zon เข้าให้แล้ว! (-", ATTACK_DAMAGE, ")")
		
# --- ระบบ Signal (คงเดิม) ---
func _on_area_2d_body_entered(body):
	if body.name == "Zon":
		player = body
		chase = true

func _on_attack_area_body_entered(body):
	if body.name == "Zon":
		can_attack = true
		attack_timer = ATTACK_COOLDOWN 
		_perform_attack()

func _on_attack_area_body_exited(body):
	if body.name == "Zon":
		can_attack = false
		attack_timer = 0.0
		
func die():
	is_dead = true
	queue_free()
