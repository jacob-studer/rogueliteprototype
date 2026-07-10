extends CharacterBody3D

const SPEED := 3.0

var player: Node3D


func _ready() -> void:
	# Find the player by group instead of a hardcoded path, so this
	# enemy scene can be placed anywhere without breaking.
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if player:
		var direction := player.global_position - global_position
		direction.y = 0.0
		direction = direction.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()
