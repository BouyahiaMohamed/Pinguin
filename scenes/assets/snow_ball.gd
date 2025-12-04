extends RigidBody3D


@export var rolling_force := 600
@export var jump_impulse := 7
@export var size := 1.0
@export var growth_speed := 0.0103
@export var max_size := 2.0
var mouse_sensitivity := 0.05
var twist_input := 0.0


func _ready() -> void:
	$CameraRig.top_level = true
	$FloorCheck.top_level = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	print(size)
	
	var old_camera_pos = $CameraRig.global_transform.origin
	var ball_pos = global_transform.origin
	var new_camera_pos = lerp(old_camera_pos, ball_pos, 0.1)
	$CameraRig.global_transform.origin = new_camera_pos
	$FloorCheck.global_transform.origin = global_transform.origin
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("ui_accept"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
		$CameraRig/Sprite3D.visible = true
	else:
		$CameraRig/Sprite3D.visible = false
	if Input.is_action_just_pressed("boost"):
		rolling_force = 900
	if Input.is_action_just_released("boost"):
		rolling_force = 300
	
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_up", "move_down")
	var force = $CameraRig.basis * input * rolling_force * delta
	apply_central_force(force)

	if Input.is_action_pressed("look_left"):
		$CameraRig.rotate_y(mouse_sensitivity)
	if Input.is_action_pressed("look_right"):
		$CameraRig.rotate_y(-mouse_sensitivity)
	if size < max_size:
		if abs(linear_velocity.x) > 2 and $FloorCheck.is_colliding():
			size += growth_speed * abs(linear_velocity.x) * delta
		elif abs(linear_velocity.z) > 2:
			size += growth_speed * abs(linear_velocity.z) * delta
	
	$CameraRig.rotate_y(twist_input * mouse_sensitivity)
	twist_input = 0.0
	
	$CollisionShape3D.scale = Vector3(size, size, size)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		size = size / 2
		print("Collision")
