extends CharacterBody2D

var player = null
var chase = false
var can_attack = false
const SPEED = 50.0
const ATTACK_DAMAGE = 10
const ATTACK_COOLDOWN = 1.0 # ระยะเวลาห่างระหว่างการกัดแต่ละครั้ง

var attack_timer = 0.0

func _physics_process(delta):
	if chase and player:
		# 1. ระบบเคลื่อนที่: เดินหา Zon
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		
		# 2. ระบบโจมตีต่อเนื่อง: ถ้าอยู่ในระยะโจมตี ให้จับเวลาลดเลือด
		if can_attack:
			attack_timer += delta
			if attack_timer >= ATTACK_COOLDOWN:
				_perform_attack()
				attack_timer = 0.0 # รีเซ็ตเวลาเพื่อรอโจมตีครั้งถัดไป
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

# ฟังก์ชันสั่งโจมตี Zon
func _perform_attack():
	if player and player.has_method("take_damage"):
		player.take_damage(ATTACK_DAMAGE)
		print("Slime: กัด Zon เข้าให้แล้ว! (-", ATTACK_DAMAGE, ")")

# --- ระบบ Signal (ตรวจสอบชื่อ Node ให้ตรงกับใน Scene ของคุณ) ---

# เมื่อ Zon เข้ามาในระยะมองเห็น (Area2D ปกติ)
func _on_area_2d_body_entered(body):
	if body.name == "Zon":
		player = body
		chase = true

# เมื่อ Zon เข้ามาในระยะประชิด (AttackArea)
func _on_attack_area_body_entered(body):
	if body.name == "Zon":
		can_attack = true
		attack_timer = ATTACK_COOLDOWN # ให้โจมตีทันทีที่แตะตัวครั้งแรก
		_perform_attack()

# เมื่อ Zon เดินหนีออกจากระยะประชิด
func _on_attack_area_body_exited(body):
	if body.name == "Zon":
		can_attack = false
		attack_timer = 0.0
