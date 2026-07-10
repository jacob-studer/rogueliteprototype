extends CharacterBody3D

const SPEED := 3.0
const ATTACK_RANGE := 1.4
const ATTACK_COOLDOWN := 1.2

@export var max_health: float = 50.0
@export var attack_damage: float = 10.0

var current_health: float
var attack_cooldown_timer := 0.0
var is_dying := false

var player: Node3D

signal died

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	current_health = max_health
	# Find the player by group instead of a hardcoded path, so this
	# enemy scene can be placed anywhere without breaking.
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:
	if is_dying:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

	if player:
		var to_player := player.global_position - global_position
		to_player.y = 0.0
		var distance := to_player.length()
		var direction := to_player.normalized()

		if distance > ATTACK_RANGE:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = 0.0
			velocity.z = 0.0
			if attack_cooldown_timer <= 0.0 and player.has_method("take_damage"):
				player.take_damage(attack_damage)
				attack_cooldown_timer = ATTACK_COOLDOWN
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()


func take_damage(amount: float) -> void:
	if is_dying:
		return
	current_health -= amount
	if current_health <= 0.0:
		_die()


func _die() -> void:
	is_dying = true
	collision_shape.disabled = true
	died.emit()

	var tween := create_tween()
	tween.tween_property(mesh_instance, "scale", Vector3.ZERO, 0.25)
	tween.tween_callback(queue_free)
