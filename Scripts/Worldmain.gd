extends Node2D

var slime_scene = preload("res://Scenes/Slime.tscn") 
var dialogue_index = 0

@onready var player = $Node2D/YSort/Zon
@onready var textbox = $Node2D/YSort/textbox
@onready var flash_screen = $ColorRect # ตรวจสอบ Path โหนดนี้ใน Scene Tree ด้วยครับ

func _ready():
	# 1. ตั้งค่าเริ่มต้น: บังจอด้วยสีขาว และหยุดการเดิน
	if flash_screen:
		flash_screen.show()
		flash_screen.modulate.a = 1.0 # ขาวทึบ 100%
	
	if player:
		player.set_physics_process(false)
	
	if textbox:
		textbox.hide() 
	
	print("1. เริ่มเกม: แสงสีขาวกำลังทำงาน")
	
	# 2. รอแสงวาบค้างไว้ 3.5 วินาที ตามแผน (Zon กำลังถูกวาร์ป)
	await get_tree().create_timer(3.5).timeout
	
	# 3. ค่อยๆ จางแสงออก (Fade Out)
	if flash_screen:
		var tween = create_tween()
		tween.tween_property(flash_screen, "modulate:a", 0, 1.5) # จางหายใน 1.5 วินาที
		await tween.finished
		flash_screen.hide() # ปิดทิ้งเพื่อไม่ให้บังเม้าส์
	
	# 4. เริ่มบทสนทนา
	start_conversation()

func start_conversation():
	if textbox:
		textbox.show()
		textbox.set_dialogue("Zon: ตอนนี้เราอยู่ที่ไหนกันเเน่...") 
		dialogue_index = 1
	
func _input(event):
	# ตรวจสอบการกด Space/Enter เพื่อเปลี่ยนบทสนทนา
	if event.is_action_pressed("ui_accept") and textbox and textbox.visible:
		dialogue_index += 1
		
		if dialogue_index == 2:
			textbox.set_dialogue("Zon: ที่นี่มันที่ไหนกัน เมื่อกี้เรายังอยู่หน้าร้านสะดวกซื้ออยู่เลยไม่ใช่เหรอ?")
		elif dialogue_index == 3:
			# จบบทสนทนา
			textbox.hide()
			if player:
				player.set_physics_process(true) # คืนค่าให้เดินได้
			print("Zon เริ่มออกเดินทางได้!")

func spawn_slime():
	var points = get_tree().get_nodes_in_group("spawn_points")
	for p in points:
		var new_slime = slime_scene.instantiate()
		new_slime.global_position = p.global_position
		add_child(new_slime)
	print("เสก Slime สำเร็จ!")
