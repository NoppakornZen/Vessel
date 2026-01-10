extends StaticBody2D

var can_pickup = false

func _ready():
	if has_node("Label"):
		$Label.hide()
	
	# เชื่อมต่อ Area ตรวจจับ
	if has_node("PickupArea"):
		$PickupArea.body_entered.connect(_on_body_entered)
		$PickupArea.body_exited.connect(_on_body_exited)

func _input(event):
	# เมื่อกด Space หรือ Enter และยืนใกล้ดาบ
	if can_pickup and event.is_action_pressed("ui_accept"):
		pickup()

func _on_body_entered(body):
	if body.name == "Zon":
		can_pickup = true
		if has_node("Label"):
			$Label.show()

func _on_body_exited(body):
	if body.name == "Zon":
		can_pickup = false
		if has_node("Label"):
			$Label.hide()

func pickup():
	# 1. ให้ Zon เปลี่ยนสถานะเป็นถือดาบ
	var zon = get_tree().current_scene.find_child("Zon")
	if zon:
		zon.change_to_sword_mode()
	
	# 2. สั่งให้ฉากหลัก (Test/Worldmain) เสก Slime ออกมา [สำคัญ!]
	if get_tree().current_scene.has_method("spawn_slime"):
		get_tree().current_scene.spawn_slime()
	else:
		print("Error: หาฟังก์ชัน spawn_slime ในฉากหลักไม่เจอ!")
	
	# 3. ลบตัวดาบทิ้ง
	queue_free()
