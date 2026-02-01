extends CharacterBody2D

# ปรับค่าหน้า Inspector
@export var speed: float = 30.0
@export var wander_range: float = 60.0 # รัศมีเดินจากจุดเกิด

var start_position: Vector2
var target_position: Vector2
var is_walking: bool = false
var last_direction: String = "Down" # เพิ่มบรรทัดนี้เพื่อเก็บทิศทางล่าสุด

@onready var timer = $Timer
@onready var sprite = $AnimatedSprite2D

func _ready():
	start_position = global_position
	_set_new_target()

func _physics_process(_delta):
	if is_walking:
		var direction = (target_position - global_position).normalized()
		velocity = direction * speed
		
		# อัปเดต Animation ตามทิศทางที่เดิน
		_update_animation(direction)
		
		move_and_slide()
		
		# ถ้าเดินถึงจุดหมายแล้ว
		if global_position.distance_to(target_position) < 5:
			is_walking = false
			velocity = Vector2.ZERO
			_play_idle_animation()
			timer.start(randf_range(2.0, 5.0)) # สุ่มเวลาหยุดพัก

func _set_new_target():
	# สุ่มพิกัดเป้าหมายใหม่รอบๆ จุดเริ่มต้น
	var random_offset = Vector2(
		randf_range(-wander_range, wander_range),
		randf_range(-wander_range, wander_range)
	)
	target_position = start_position + random_offset
	is_walking = true

func _update_animation(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			sprite.play("Run_Right")
			last_direction = "Right"
		else:
			sprite.play("Run_Left")
			last_direction = "Left"
	else:
		if dir.y > 0:
			sprite.play("Run_Down")
			last_direction = "Down"
		else:
			sprite.play("Run_Up")
			last_direction = "Up"

func _play_idle_animation():
	# เล่นท่า Idle ให้ตรงกับทิศทางที่เพิ่งเดินมา
	sprite.play("Idle_" + last_direction)

func _on_timer_timeout():
	_set_new_target()


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
