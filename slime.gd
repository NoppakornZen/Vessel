extends CharacterBody2D

var player = null
var chase = false
var can_attack = false
const SPEED = 50.0

func _physics_process(_delta):
	if chase and player:
		# คำนวณทิศทางหา Zon
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO
	
	move_and_slide() # ทำให้ Slime เคลื่อนที่จริง

# สัญญาณเมื่อ Zon เข้ามาในระยะมองเห็น
func _on_area_2d_body_entered(body):
	if body.name == "Zon":
		player = body
		chase = true

# สัญญาณเมื่อ Zon ออกจากระยะโจมตี (คุณต้องเพิ่ม Signal นี้ในหน้า Node ด้วยนะครับ)
func _on_attack_area_body_entered(body):
	if body.name == "Zon":
		can_attack = true
		if body.has_method("take_damage"):
			body.take_damage(10) # สั่งให้ Zon ลดเลือด
