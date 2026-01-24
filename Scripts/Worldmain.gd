extends Node2D

var slime_scene = preload("res://Scenes/Slime.tscn") 
var dialogue_index = 0
var zayryu_event_triggered = false
var sword_found_triggered = false
var battle_started = false 
var dialogue_list = [] 
var current_line = 0   
var current_portrait: Texture2D = null

# 1. ตรวจสอบ Path ตรงนี้ให้ดีที่สุด!
# ถ้าลาก Textbox มาไว้ใน Worldmain แล้ว Path ต้องตรงกับใน Scene Tree
@onready var player = $Node2D/YSort/Zon
@onready var textbox = $Node2D/YSort/textbox
@onready var flash_screen = $ColorRect 

func _ready():
	if flash_screen:
		flash_screen.show()
		flash_screen.modulate.a = 1.0
	
	if player: 
		player.set_physics_process(false)
	
	if textbox: 
		textbox.hide() 
	else:
		print("CRITICAL ERROR: หาโหนด textbox ไม่เจอในฉากนี้!")
	
	await get_tree().create_timer(3.5).timeout
	
	if flash_screen:
		var tween = create_tween()
		tween.tween_property(flash_screen, "modulate:a", 0, 1.5)
		await tween.finished
		flash_screen.hide()
	
	start_conversation()

func start_conversation():
	dialogue_list = [
		"ที่นี่ที่ไหนกัน น่ากลัวชะมัด ฉันเพิ่งเดินออกมาจากร้านสะดวกซื้อเอง",
		"มืดชะมัด... ฉันต้องรีบหาทางออกไปจากป่านี้ให้เร็วที่สุด"
	]
	current_line = 0
	
	# 2. ป้องกันเกมค้างถ้าหาไฟล์รูปไม่เจอ
	var zon_portrait = null
	if FileAccess.file_exists("res://Zon_Base_Sheet.png"):
		zon_portrait = load("res://Zon_Base_Sheet.png")
	
	start_dialogue("", dialogue_list, zon_portrait)

func _input(event):
	if event.is_action_pressed("interact") and textbox and textbox.visible:
		current_line += 1
		if current_line < dialogue_list.size():
			textbox.update_dialogue("", dialogue_list[current_line], current_portrait)
			get_viewport().set_input_as_handled()
		else:
			finish_dialogue()
			get_viewport().set_input_as_handled()

func start_dialogue(n_name: String, n_text: Array, n_portrait: Texture2D = null):
	print("เริ่มทำงาน start_dialogue") 
	dialogue_list = n_text
	current_line = 0
	current_portrait = n_portrait 
	
	if player: player.set_physics_process(false)
	
	if textbox:
		textbox.show()
		# ส่งค่าว่างไปที่ชื่อ (n_name) เพื่อไม่ให้แสดงชื่อตามที่คุณต้องการ
		textbox.update_dialogue("", dialogue_list[current_line], n_portrait)
	else:
		print("Error: สั่งโชว์ Textbox ไม่ได้ เพราะหาโหนดไม่เจอ!")

func finish_dialogue():
	if textbox: textbox.hide()
	if player: player.set_physics_process(true)
	
	if dialogue_index == 13:
		spawn_slime()
	
	dialogue_index = -1

# --- ส่วนของ Events (ไม่ต้องแก้เยอะ แค่เรียกใช้ start_dialogue) ---

func _on_zayryu_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Zon" and not zayryu_event_triggered:
		zayryu_event_triggered = true
		dialogue_index = 10
		start_dialogue("", ["บรรยากาศน่าขนลุกชะมัด ป่าที่ไหนหละเนี่ย อยากกลับบ้านเเล้วเว้ย"], current_portrait)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Zon" and not sword_found_triggered:
		sword_found_triggered = true
		dialogue_index = 13
		start_dialogue("", ["เฮ้ยย อะไรวะนั้นสวยชะมัด ลองเเตะดูจะเป็นไรเปล่าวะ หยิบดูก็คงไม่เป็นไรหรอกมั้ง"], current_portrait)

func check_enemies_cleared():
	await get_tree().process_frame 
	if not battle_started: return
	var enemies = get_tree().get_nodes_in_group("mobs")
	if enemies.size() == 0:
		battle_started = false 
		dialogue_index = 20
		start_dialogue("", ["ห๊า??!! ตัวไรวะ ที่นี่เเม่งเเปลกๆเเล้ว บนโลกมีสัตว์เเบบนี้ด้วยอ่อวะ"], current_portrait)

func spawn_slime():
	if battle_started: return 
	battle_started = true 
	var points = get_tree().get_nodes_in_group("spawn_points")
	var ysort_node = $Node2D/YSort 
	for p in points:
		var new_slime = slime_scene.instantiate()
		new_slime.global_position = p.global_position
		new_slime.slime_died.connect(check_enemies_cleared) 
		new_slime.add_to_group("mobs") 
		ysort_node.add_child(new_slime)
