extends Node2D

var slime_scene = preload("res://Scenes/Slime.tscn") 
var dialogue_index = 0
var zayryu_event_triggered = false
var sword_found_triggered = false
var battle_started = false 

@onready var player = $Node2D/YSort/Zon
@onready var textbox = $Node2D/YSort/textbox
@onready var flash_screen = $ColorRect 

func _ready():
	if flash_screen:
		flash_screen.show()
		flash_screen.modulate.a = 1.0
	if player: player.set_physics_process(false)
	if textbox: textbox.hide() 
	
	await get_tree().create_timer(3.5).timeout
	if flash_screen:
		var tween = create_tween()
		tween.tween_property(flash_screen, "modulate:a", 0, 1.5)
		await tween.finished
		flash_screen.hide()
	start_conversation()

func start_conversation():
	if textbox:
		textbox.show()
		textbox.set_dialogue("Zon: Huh!!? Where am I? I just walked out of the store.") 
		dialogue_index = 1
	
func _input(event):
	if event.is_action_pressed("ui_accept") and textbox and textbox.visible:
		if dialogue_index == 1:
			dialogue_index = 2
			textbox.set_dialogue("Zon: I need to get out of here as soon as possible.")
		elif dialogue_index == 2:
			dialogue_index = 3
			textbox.hide()
			if player: player.set_physics_process(true)
		elif dialogue_index == 10:
			dialogue_index = 11
			textbox.set_dialogue("Zon: What's that blue light? It's up there....")
		elif dialogue_index == 11:
			dialogue_index = 12
			textbox.set_dialogue("Zon: I feel like it's calling out to me")
		elif dialogue_index == 12:
			textbox.hide()
			if player: player.set_physics_process(true)
		elif dialogue_index == 13:
			textbox.hide()
			if player: player.set_physics_process(true)
			spawn_slime() # เริ่มการต่อสู้ [cite: 2026-01-02]
		elif dialogue_index == 20:
			dialogue_index = 21
			textbox.set_dialogue("Zon: What's it like here? It's so different  from the world I used to live in.")
		elif dialogue_index == 21:
			textbox.hide()

func spawn_slime():
	if battle_started: return 
	battle_started = true 
	
	var points = get_tree().get_nodes_in_group("spawn_points")
	var ysort_node = $Node2D/YSort 
	
	for p in points:
		var new_slime = slime_scene.instantiate()
		new_slime.global_position = p.global_position
		
		# สำคัญ: เชื่อมสัญญาณตายของ Slime เข้ากับฟังก์ชันเช็คศัตรู [cite: 2026-01-02]
		new_slime.slime_died.connect(check_enemies_cleared) 
		
		new_slime.add_to_group("mobs") # ใส่กลุ่มที่ตัวละครหลักเลย [cite: 2026-01-02]
		ysort_node.add_child(new_slime)

func _on_zayryu_trigger_body_entered(body: Node2D) -> void:
	if body.name == "Zon" and not zayryu_event_triggered:
		zayryu_event_triggered = true
		if player: player.set_physics_process(false)
		if textbox:
			textbox.show()
			textbox.set_dialogue("Zon: Huh? Why are things around me making me anxious?")
			dialogue_index = 10

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Zon" and not sword_found_triggered:
		sword_found_triggered = true
		if player: player.set_physics_process(false)
		if textbox:
			textbox.show()
			textbox.set_dialogue("Zon: Huh? What is this, It's a real sword? It looks very beautiful.")
			dialogue_index = 13
			
func check_enemies_cleared():
	# 1. รอให้ระบบลบ Slime ที่เพิ่งตายออกไปจากหน่วยความจำก่อน [cite: 2026-01-02]
	await get_tree().process_frame 
	
	# 2. ตรวจสอบว่าอยู่ในช่วงต่อสู้หรือไม่ (ถ้าไม่ได้สู้ก็ไม่ต้องเช็ค) [cite: 2026-01-02]
	if not battle_started: 
		return
	
	# 3. นับจำนวนโหนดที่มีกลุ่มชื่อ "mobs" เหลืออยู่ในฉาก [cite: 2026-01-02]
	var enemies = get_tree().get_nodes_in_group("mobs")
	print("ระบบนับศัตรู: เหลืออีก ", enemies.size(), " ตัว") # บรรทัดนี้จะบอกเราใน Output [cite: 2026-01-02]
	
	# 4. ถ้าเหลือ 0 ตัว (ตายหมดแล้ว) ให้ทำงานต่อ [cite: 2026-01-02]
	if enemies.size() == 0:
		print("--- ศัตรูหมดแล้ว! กำลังเริ่มบทสนทนา ---")
		battle_started = false # ปิดโหมดต่อสู้ [cite: 2026-01-02]
		
		# สั่งให้ Zon หยุดเดินทันที [cite: 2026-01-02]
		if player:
			player.set_physics_process(false)
		
		# แสดง TextBox และตั้งค่าบทสนทนาไปที่ลำดับที่ 20 (ตามที่คุณตั้งไว้) [cite: 2026-01-02]
		if textbox:
			textbox.show()
			textbox.set_dialogue("Zon: What the heck is that?")
			dialogue_index = 20
