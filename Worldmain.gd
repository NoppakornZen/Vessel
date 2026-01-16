extends Node2D

# เช็กว่าใน FileSystem ของคุณ ไฟล์ชื่อ Slime.tscn (S ตัวใหญ่) หรือ slime.tscn (s ตัวเล็ก)
# จากรูป image_890bf0.png ของคุณต้องเป็น "res://Slime.tscn" นะครับ
var slime_scene = preload("res://Scenes/Slime.tscn") 

func spawn_slime():
	var points = get_tree().get_nodes_in_group("spawn_points")
	for p in points:
		var new_slime = slime_scene.instantiate()
		new_slime.global_position = p.global_position
		add_child(new_slime)
	print("เสก Slime สำเร็จ!")
