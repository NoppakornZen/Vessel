extends Node2D

# เช็กว่าใน FileSystem ของคุณ ไฟล์ชื่อ Slime.tscn (S ตัวใหญ่) หรือ slime.tscn (s ตัวเล็ก)
# จากรูป image_890bf0.png ของคุณต้องเป็น "res://Slime.tscn" นะครับ
var slime_scene = preload("res://Scenes/Slime.tscn") 
var dialogue_index = 0

@onready var player = $Zon
@onready var textbox = $Textbox
@onready var flash_screen = $ColorRect # แสงสีขาว

func _ready():
	# 1. เริ่มเกม: บังคับไม่ได้ และเปิดแสงสีขาว
	player.set_physics_process(false)
	textbox.hide() 
	
	# 2. รอแสงวาบ 3-4 วินาที (ใช้ Timer แบบโค้ด)
	await get_tree().create_timer(3.5).timeout
	
	# 3. ค่อยๆ จางแสงออก (Fade Out) และเริ่มคุย
	var tween = create_tween()
	tween.tween_property(flash_screen, "modulate:a", 0, 1.0) # จางหายใน 1 วินาที
	await tween.finished
	
	start_conversation()
	
func start_conversation():
	textbox.show()
	dialogue_index = 1
	textbox.set_dialogue("Zon: ตอนนี้เราอยู่ที่ไหนกันเเน่...")
	
func _input(event):
	# ถ้ากด Space/Enter และกล่องข้อความเปิดอยู่
	if event.is_action_pressed("ui_accept") and textbox.visible:
		dialogue_index += 1
		
		if dialogue_index == 2:
			textbox.set_dialogue("Zon: ที่นี่มันที่ไหนกัน เมื่อกี้เรายังอยู่หน้าหน้าร้านสะดวกซื้ออยู่เลยไม่ใช่เหรอ?")
		
		elif dialogue_index == 3:
			# 4. จบบทสนทนา: ปิดกล่อง และให้เดินได้
			textbox.hide()
			player.set_physics_process(true)


func spawn_slime():
	var points = get_tree().get_nodes_in_group("spawn_points")
	for p in points:
		var new_slime = slime_scene.instantiate()
		new_slime.global_position = p.global_position
		add_child(new_slime)
	print("เสก Slime สำเร็จ!")
