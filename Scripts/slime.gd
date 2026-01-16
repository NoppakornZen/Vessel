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
@onready var sprite = $AnimatedSprite2D # หรือชื่อ Node Sprite ของคุณ

var attack_timer = 0.0
var knockback_velocity = Vector2.ZERO

func _ready():
	add_to_group("mobs") 
	health_bar.max_value = max_hp
	health_bar.value = current_hp

func _physics_process(delta):
	if is_dead: return
	
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, 0.1)
	elif chase and player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()

# --- ฟังก์ชันรับดาเมจและการกะพริบแดง (รวมไว้ที่นี่ที่เดียว) ---
func take_damage(amount: int, knockback_force: Vector2):
	if is_dead: return
	
	current_hp -= amount
	health_bar.value = current_hp
	knockback_velocity = knockback_force
	
	# เพิ่มความหยุดชะงัก (Hit Stun) เล็กน้อยให้ดูเหมือนโดนฟันจริงๆ
	chase = false # หยุดเดินตามครู่หนึ่ง
	hit_flash()
	
	# รอ 0.2 วินาทีค่อยกลับมาไล่ตามต่อ
	await get_tree().create_timer(0.2).timeout
	if not is_dead:
		chase = true
	
	if current_hp <= 0:
		die()

func hit_flash():
	# ใช้สีขาวสว่างจ้า (White Flash) จะดูเป็นเกมแอ็กชันมากกว่าสีแดงล้วนครับ
	modulate = Color(5, 5, 5) 
	await get_tree().create_timer(0.08).timeout # กะพริบไวๆ จะดูคมกว่า
	modulate = Color(1, 1, 1)

func die():
	is_dead = true
	queue_free()

# --- สัญญาณสำหรับไล่ตาม (Area2D วงกลมใหญ่) ---
func _on_area_2d_body_entered(body):
	if body.name == "Zon":
		player = body
		chase = true

# --- สัญญาณสำหรับรับดาเมจจากดาบ (Area2D_2 อันเล็กเท่าตัว) ---
func _on_area_2d_2_area_entered(area):
	if area.name == "ZayryuHitbox" or area.is_in_group("weapon"):
		var zon = area.get_parent()
		# เช็คว่า Zon กำลังฟันอยู่จริงๆ
		if zon and zon.get("is_attacking") == true:
			# เรียกใช้ฟังก์ชันรับดาเมจ
			var knockback_dir = (global_position - zon.global_position).normalized()
			take_damage(30, knockback_dir * 400.0)
			print("Slime: โอ๊ย! โดน Zayryu ฟันเข้าให้แล้ว")
