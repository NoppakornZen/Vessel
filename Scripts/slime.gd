extends CharacterBody2D

var player = null
var chase = false
var can_attack = false
var max_hp = 200 
var current_hp = 200
var is_dead = false

const SPEED = 50.0
const ATTACK_DAMAGE = 10
const ATTACK_COOLDOWN = 1.0 

@onready var health_bar = $ProgressBar 
@onready var sprite = $AnimatedSprite2D

var attack_timer = 0.0
var knockback_velocity = Vector2.ZERO

func _ready():
	add_to_group("mobs") 
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func _physics_process(delta):
	if is_dead: return
	
	# 1. จัดการแรงผลัก (Knockback)
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)
	
	# 2. ระบบ AI วิ่งไล่และโจมตี
	elif chase and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		
		# เช็คว่าถ้าอยู่ประชิดตัว (can_attack) ให้เริ่มนับเวลาถอยหลังเพื่อกัด
		if can_attack:
			attack_timer += delta
			if attack_timer >= ATTACK_COOLDOWN:
				_perform_attack() # เรียกใช้ฟังก์ชันกัด (Error จะหายไป)
				attack_timer = 0.0 
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

# --- ฟังก์ชันใหม่: สั่งกัด Zon (เพิ่มส่วนนี้เข้าไป Error บรรทัด 46 จะหายครับ) ---
func _perform_attack():
	if player and player.has_method("take_damage"):
		var knockback_dir = (player.global_position - global_position).normalized()
		# ส่งดาเมจ 10 และแรงผลักให้ Zon
		player.take_damage(ATTACK_DAMAGE, knockback_dir * 300.0) 
		print("Slime: กัด Zon เข้าให้แล้ว! (-", ATTACK_DAMAGE, ")")

# --- ฟังก์ชันรับดาเมจ (ปรับปรุงให้รองรับค่า Crit) ---
func take_damage(amount: int, knockback_force: Vector2, is_crit: bool = false):
	if is_dead: return
	
	current_hp -= amount
	health_bar.value = current_hp
	knockback_velocity = knockback_force
	
	chase = false 
	
	if is_crit:
		hit_flash_crit()
	else:
		hit_flash()
	
	await get_tree().create_timer(0.2).timeout
	if not is_dead:
		chase = true
	
	if current_hp <= 0:
		die()

func hit_flash():
	modulate = Color(5, 5, 5) 
	await get_tree().create_timer(0.08).timeout 
	modulate = Color(1, 1, 1)

func hit_flash_crit():
	modulate = Color(10, 8, 0) 
	await get_tree().create_timer(0.12).timeout 
	modulate = Color(1, 1, 1)

func die():
	is_dead = true
	queue_free()

# --- ระบบ Signal (ตรวจสอบให้ชื่อฟังก์ชันตรงกับที่เชื่อมไว้ใน Editor) ---
func _on_area_2d_body_entered(body):
	if body.name == "Zon":
		player = body
		chase = true

func _on_attack_area_body_entered(body): # Area สำหรับระยะกัด
	if body.name == "Zon":
		can_attack = true
		attack_timer = ATTACK_COOLDOWN # ให้กัดทีแรกทันทีที่ถึงตัว

func _on_attack_area_body_exited(body):
	if body.name == "Zon":
		can_attack = false
		attack_timer = 0.0

func _on_area_2d_2_area_entered(area):
	if area.name == "ZayryuHitbox" or area.is_in_group("weapon"):
		var zon = area.get_parent()
		if zon and zon.get("is_attacking") == true:
			var crit_active = zon.get("is_crit") 
			var damage = 60 if crit_active else 30
			var knockback_power = 800.0 if crit_active else 400.0
			var knockback_dir = (global_position - zon.global_position).normalized()
			take_damage(damage, knockback_dir * knockback_power, crit_active)
