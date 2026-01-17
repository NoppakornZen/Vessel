extends Node2D

var slime_scene = preload("res://Scenes/Slime.tscn") 
var dialogue_index = 0
var zayryu_event_triggered = false

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
	
	print("1. เริ่มเกม: แสงสีขาวกำลังทำงาน")
	
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
		# --- ช่วงที่ 1: บทสนทนาเริ่มเกม ---
		if dialogue_index == 1:
			dialogue_index = 2
			textbox.set_dialogue("Zon: I need to get out of here as soon as possible.")
		elif dialogue_index == 2:
			dialogue_index = 3
			textbox.hide()
			if player:
				player.set_physics_process(true)
			print("Zon เริ่มออกเดินทางได้!")
		
		# --- ช่วงที่ 2: บทสนทนาตอนเข้าใกล้ดาบ ---
		elif dialogue_index == 10:
			dialogue_index = 11
			textbox.set_dialogue("Zon: What's that blue light? It's up there....") # อันนี้จะต่อจาก func _on_zayryu_trigger_body_entered ไม่ให้เกมค้าง
		elif dialogue_index == 11:
			dialogue_index = 12
			textbox.set_dialogue("Zon: I feel like it's calling out to me")
		elif dialogue_index == 12:
			textbox.hide()
			if player:
				player.set_physics_process(true)
			print("Zon มุ่งหน้าไปหาดาบ!")

func spawn_slime():
	var points = get_tree().get_nodes_in_group("spawn_points")
	var ysort_node = $Node2D/YSort 
	
	for p in points:
		var new_slime = slime_scene.instantiate()
		new_slime.global_position = p.global_position
		new_slime.y_sort_enabled = true 
		new_slime.z_index = 0
		ysort_node.add_child(new_slime)

func _on_zayryu_trigger_body_entered(body: Node2D) -> void:
	# ตรวจสอบว่าต้องเป็น Zon เท่านั้น และเหตุการณ์นี้ยังไม่เคยเกิดขึ้น
	if body.name == "Zon" and not zayryu_event_triggered:
		zayryu_event_triggered = true # ล็อคไว้ไม่ให้เกิดซ้ำ [cite: 2026-01-02]
		
		if player:
			player.set_physics_process(false) # หยุดเดินชั่วคราว [cite: 2026-01-02]
		
		if textbox:
			textbox.show()
			textbox.set_dialogue("Zon: Huh? Why are things around me making me anxious?")
			dialogue_index = 10 # เริ่มต้นลำดับบทสนทนาช่วงที่ 2 [cite: 2026-01-02]
