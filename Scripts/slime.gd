extends CharacterBody2D

var player = null
var chase = false
var can_attack = false
const SPEED = 50.0
const ATTACK_DAMAGE = 10
const ATTACK_COOLDOWN = 1.0 

var attack_timer = 0.0
# --- เพิ่มส่วนประกอบสำหรับแรงผลัก (Knockback) ---
var knockback_velocity = Vector2.ZERO

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
func take_damage(force):
	# รับแรงผลักที่ส่งมาจากดาบ Zayryu
	knockback_velocity = force
	print("Slime: อ๊ากก! โดนดาบ Zayryu ฟันกระเด็น!")

# ฟังก์ชันสั่งโจมตี Zon (คงเดิม)
func _perform_attack():
	if player and player.has_method("take_damage"):
		player.take_damage(ATTACK_DAMAGE)
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
