extends CanvasLayer

@onready var label = $MarginContainer/Panel/MarginContainer/Panel/HBoxContainer/Label

# ฟังก์ชันสำหรับเปลี่ยนข้อความจากภายนอก
func set_dialogue(text: String):
	label.text = text
