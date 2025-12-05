extends RigidBody3D

@export var rolling_force := 800
@export var mouse_sensitivity := 0.05
@export var visual_size := 0.035

@onready var ModelPivot: Node3D = $ModelPivot 
@onready var mesh_instance_3d: MeshInstance3D = $ModelPivot/MeshInstance3D
@onready var floor_check: RayCast3D = $FloorCheck
@onready var camera_rig: Node3D = $CameraRig
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var game_over_1: Panel = $"../CanvasLayer/GameOver1" 
@onready var end: Panel = $"../CanvasLayer/End"

var reset_position = false
var twist_input := 0.0

var is_dead = false 

func _ready() -> void:
	ModelPivot.top_level = true
	camera_rig.top_level = true
	floor_check.top_level = true

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


	if game_over_1:
		game_over_1.visible = false

func _physics_process(delta: float) -> void:

	camera_rig.global_position = camera_rig.global_position.lerp(global_position, 0.2)
	floor_check.global_position = global_position

	if is_dead:

		linear_velocity = Vector3.ZERO
		angular_velocity = Vector3.ZERO
		return 

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("boost"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	
	var current_force = 900 if Input.is_action_pressed("boost") else rolling_force

	var force = camera_rig.basis * current_force * delta * Vector3(0 * input.x, 0, -1)
	apply_central_force(force)

	if Input.is_action_pressed("look_left"): camera_rig.rotate_y(mouse_sensitivity)
	if Input.is_action_pressed("look_right"): camera_rig.rotate_y(-mouse_sensitivity)
	
	camera_rig.rotate_y(twist_input * mouse_sensitivity)
	twist_input = 0.0

	_gerer_visuel(delta)

func _gerer_visuel(delta: float) -> void:
	# 1. Calcul de la position de base (au sol)
	var target_position = global_position
	
	if floor_check.is_colliding():
		target_position = floor_check.get_collision_point()
	else:
		target_position.y -= 0.3

	var velocity = linear_velocity
	var speed = velocity.length()
	var target_basis: Basis

	if speed > 5.0:

		target_position.y += 0.3
		
		var dir = velocity.normalized()
		if dir.cross(Vector3.UP).length() > 0.01:
			target_basis = Basis.looking_at(dir, Vector3.UP)
			target_basis = target_basis.rotated(Vector3.UP, deg_to_rad(180))
			target_basis = target_basis.rotated(target_basis.x, deg_to_rad(90))
	else:
		# --- MODE DEBOUT ---
		target_basis = Basis(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1))
		var cam_rot_y = camera_rig.global_rotation.y
		target_basis = target_basis.rotated(Vector3.UP, cam_rot_y + deg_to_rad(180))

	ModelPivot.global_position = ModelPivot.global_position.lerp(target_position, 20 * delta)
		
	if target_basis:
		ModelPivot.global_transform.basis = ModelPivot.global_transform.basis.slerp(target_basis, 10 * delta)
func _unhandled_input(event: InputEvent) -> void:
	if is_dead: return
		
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		twist_input = - event.relative.x * mouse_sensitivity

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if reset_position:
		state.transform.origin = Vector3(0, 1, 0)
		state.linear_velocity = Vector3.ZERO
		state.angular_velocity = Vector3.ZERO
		reset_position = false

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self and not is_dead:
		print("Mort !")
		is_dead = true
		game_over_1.visible = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_button_pressed() -> void:
	print('Respawn !')
	reset_position = true
	is_dead = false
	game_over_1.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_end_body_entered(body: Node3D) -> void:
	if body == self:
		end.visible = true
