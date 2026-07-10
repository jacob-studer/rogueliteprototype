extends CharacterBody3D

const SPEED := 5.0

@onready var camera_pivot: Node3D = $CameraPivot


func _physics_process(delta: float) -> void:
	# Apply gravity so the player stays on the floor.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Read WASD input (defined in Project Settings -> Input Map).
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# Move relative to where the camera is facing.
	var cam_basis := camera_pivot.global_transform.basis
	var direction := (cam_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	direction.y = 0.0
	direction = direction.normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)
		velocity.z = move_toward(velocity.z, 0.0, SPEED)

	move_and_slide()
