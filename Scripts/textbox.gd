extends CanvasLayer

# 1. อ้างอิงที่อยู่โหนดตามโครงสร้างจริงในรูป image_317037.png
# สังเกตว่าต้องมี Panel -> MarginContainer -> Panel ตามลำดับที่คุณทำไว้ครับ
@onready var display_label = $MarginContainer/Panel/MarginContainer/Panel/HBoxContainer/Label
@onready var portrait_node = $MarginContainer/Panel/MarginContainer/Panel/HBoxContainer/TextureRect

var is_active: bool = false

func _ready():
	hide()
	

# ฟังก์ชันรับค่า ชื่อ, ข้อความ, และรูปภาพ [cite: 2026-01-02]
func update_dialogue(speaker_name: String, text_content: String, portrait_texture: Texture2D = null):
	show()
	is_active = true
	
	# ป้องกัน Error ถ้าหาโหนดไม่เจอ จะได้รู้ว่าจุดไหนผิด
	if display_label:
		display_label.text = speaker_name + ": " + text_content
		display_label.visible_ratio = 0
		var tween = create_tween()
		tween.tween_property(display_label, "visible_ratio", 1.0, 1.0).set_trans(Tween.TRANS_LINEAR)
	else:
		print("Error: หาโหนด Label ไม่เจอ! เช็ค Path ใน @onready")
	
	if portrait_texture != null and portrait_node:
		portrait_node.texture = portrait_texture

func _input(event):
	if is_active and event.is_action_pressed("ui_accept"):
		_close_textbox()

func _close_textbox():
	hide()
	is_active = false
	var player = get_tree().root.find_child("Zon", true, false)
	if player:
		player.set_physics_process(true)
