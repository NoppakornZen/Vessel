extends StaticBody2D

var can_pickup = false

func _ready():
	# 1. ซ่อนข้อความไว้ก่อนตอนเริ่มเกม
	if has_node("Label"):
		$Label.hide()
	
	# เชื่อมต่อระบบตรวจจับ (เช็คชื่อ Node ให้ตรงกับใน Scene)
	if has_node("PickupArea"):
		$PickupArea.body_entered.connect(_on_body_entered)
		$PickupArea.body_exited.connect(_on_body_exited)
	elif has_node("Area2D"):
		$Area2D.body_entered.connect(_on_body_entered)
		$Area2D.body_exited.connect(_on_body_exited)

func _input(event):
	if can_pickup and event.is_action_pressed("ui_accept"):
		pickup()

func _on_body_entered(body):
	if body.name == "Zon":
		can_pickup = true
		# 2. เมื่อ Zon เดินเข้ามาใกล้ ให้โชว์ข้อความ
		if has_node("Label"):
			$Label.show()

func _on_body_exited(body):
	if body.name == "Zon":
		can_pickup = false
		# 3. เมื่อ Zon เดินออกไป ให้ซ่อนข้อความ
		if has_node("Label"):
			$Label.hide()

func pickup():
	var zon = get_tree().current_scene.find_child("Zon")
	if zon:
		zon.change_to_sword_mode()
	
	queue_free() # เมื่อเก็บแล้ว ดาบและข้อความจะหายไปพร้อมกัน
