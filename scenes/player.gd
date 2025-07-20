extends CharacterBody3D
@export_group("Camera")
@export_range(0.0,1.0) var mouse_sensitivity := 0.01
@export var speed = 14
@export var fall_acceleration = 75

var target_velocity := Vector3.ZERO
var _camera_input_direction := Vector2.ZERO

@onready var _camera_pivot: Node3D = %CameraPivot
@onready var _spring_arm: Node3D = %SpringArm3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_released("right_click"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("wheel_up"):
		_spring_arm.spring_length -=1
	if event.is_action_pressed("wheel_down"):
		_spring_arm.spring_length +=1

func _unhandled_input(event: InputEvent) -> void:
	var is_camera_notion := (
		event is InputEventMouseMotion and 
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_notion:
		_camera_input_direction = event.screen_relative * mouse_sensitivity
		_camera_pivot.rotation.x -= _camera_input_direction.y
		_camera_pivot.rotation.x = clamp(_camera_pivot.rotation.x,-PI / 3.0, PI / 1.5)
		_camera_pivot.rotation.y -= _camera_input_direction.x
		_camera_input_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("down"):
		direction.z += 1
	if Input.is_action_pressed("up"):
		direction.z -= 1
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		target_velocity.x = direction.x
		target_velocity.z = direction.z
		target_velocity = transform.basis * direction
		target_velocity *= speed
		rotation.y = _camera_pivot.rotation.y
	else:
		target_velocity = Vector3.ZERO
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	velocity = target_velocity
	move_and_slide()
	_camera_pivot.position = position + Vector3(0,0.78,0)
