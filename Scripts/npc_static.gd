extends "res://Scripts/npc_base.gd.gd" # ตรวจสอบชื่อไฟล์แม่ให้ตรงกับในเครื่องคุณ

# --- Dialogue Settings (จะปรากฏใน Inspector) ---
@export var npc_name: String = "พนักงานกิลด์"
@export var npc_portrait: Texture2D # ช่องสำหรับลากรูปหน้า NPC มาใส่
@export var dialogue_lines: Array[String] = ["สวัสดี Zon ยินดีต้อนรับสู่กิลด์!"]

var is_player_nearby: bool = false # เช็คว่า Zon อยู่ใกล้พอจะคุยไหม

func _input(event):
	# ถ้าอยู่ใกล้และกดปุ่ม E (หรือ ui_accept)
	if is_player_nearby and event.is_action_pressed("ui_accept"):
		_start_conversation()

func _start_conversation():
	# ค้นหาโหนด Textbox ที่อยู่ในฉาก
	var textbox = get_tree().root.find_child("textbox", true, false)
	
	if textbox:
		# ส่งข้อมูล ชื่อ, ข้อความแรก, และรูป Portrait ไปเปลี่ยนที่ Textbox
		textbox.update_dialogue(npc_name, dialogue_lines[0], npc_portrait)
		
		# (เพิ่มเติม) ล็อกตัวละคร Zon ไม่ให้เดินขณะคุย
		var player = get_tree().root.find_child("Zon", true, false)
		if player:
			player.set_physics_process(false)
	else:
		print("Error: หาโหนด Textbox ไม่เจอ!")

# --- Signal Connections (เชื่อมจาก Area2D) ---
func _on_area_2d_body_entered(body):
	if body.name == "Zon": # มั่นใจว่าตัวที่เดินเข้ามาคือ Zon
		is_player_nearby = true

func _on_area_2d_body_exited(body):
	if body.name == "Zon":
		is_player_nearby = false
