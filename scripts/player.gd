extends CharacterBody3D

const BASE_SPEED := 5.0
const ATTACK_COOLDOWN := 0.5
const INVULN_DURATION := 1.0

@export var max_health: float = 100.0
@export var attack_damage: float = 25.0

var speed := BASE_SPEED
var current_health: float
var is_dead := false

var attack_cooldown_timer := 0.0
var invuln_timer := 0.0

signal health_changed(current: float, max_value: float)
signal died

@onready var camera_pivot: Node3D = $CameraPivot
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var attack_area: Area3D = $AttackArea


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func _physics_process(delta: float) -> void:
	if attack_cooldown_timer > 0.0:
		attack_cooldown_timer -= delta

	_update_invulnerability(delta)

	if is_dead:
		# Let the player settle to the floor but ignore input while dead.
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	var cam_basis := camera_pivot.global_transform.basis
	var direction := (cam_basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	direction.y = 0.0
	direction = direction.normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)
		velocity.z = move_toward(velocity.z, 0.0, speed)

	move_and_slide()

	if Input.is_action_just_pressed("attack"):
		try_attack()


func _update_invulnerability(delta: float) -> void:
	if invuln_timer > 0.0:
		invuln_timer -= delta
		# Flicker the mesh while invulnerable so the hit is readable.
		mesh_instance.visible = int(invuln_timer * 10.0) % 2 == 0
	else:
		mesh_instance.visible = true


func try_attack() -> void:
	if is_dead or attack_cooldown_timer > 0.0:
		return
	attack_cooldown_timer = ATTACK_COOLDOWN
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(attack_damage)


func take_damage(amount: float) -> void:
	if is_dead or invuln_timer > 0.0:
		return
	current_health = max(current_health - amount, 0.0)
	health_changed.emit(current_health, max_health)
	if current_health <= 0.0:
		_die()
	else:
		invuln_timer = INVULN_DURATION


func _die() -> void:
	is_dead = true
	died.emit()


func increase_max_health(amount: float) -> void:
	max_health += amount
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


func increase_attack_damage(amount: float) -> void:
	attack_damage += amount


func increase_speed(amount: float) -> void:
	speed += amount
