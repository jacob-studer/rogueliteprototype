extends Node3D

const RewardPickupScene := preload("res://scenes/RewardPickup.tscn")

const REWARD_SPAWN_POINTS := [
	Vector3(-2, 1, 3),
	Vector3(0, 1, 3),
	Vector3(2, 1, 3),
]
const REWARD_TYPES := ["health", "damage", "speed"]

var enemies_alive := 0

@onready var player: CharacterBody3D = $Player
@onready var door_mesh: MeshInstance3D = $Door/MeshInstance3D
@onready var door_collision: CollisionShape3D = $Door/CollisionShape3D
@onready var enemies_root: Node3D = $Enemies
@onready var ui: CanvasLayer = $UI


func _ready() -> void:
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)
	ui.set_health(player.current_health, player.max_health)

	var enemies := enemies_root.get_children()
	enemies_alive = enemies.size()
	ui.set_enemy_count(enemies_alive)
	for enemy in enemies:
		enemy.died.connect(_on_enemy_died)


func _process(_delta: float) -> void:
	if player.is_dead and Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()


func _on_player_health_changed(current: float, max_value: float) -> void:
	ui.set_health(current, max_value)


func _on_player_died() -> void:
	ui.show_death_screen()


func _on_enemy_died() -> void:
	enemies_alive = max(enemies_alive - 1, 0)
	ui.set_enemy_count(enemies_alive)
	if enemies_alive == 0:
		_unlock_exit()


func _unlock_exit() -> void:
	door_mesh.visible = false
	door_collision.disabled = true
	ui.show_room_cleared()
	_spawn_rewards()


func _spawn_rewards() -> void:
	for i in REWARD_SPAWN_POINTS.size():
		var reward := RewardPickupScene.instantiate()
		reward.reward_type = REWARD_TYPES[i]
		add_child(reward)
		reward.position = REWARD_SPAWN_POINTS[i]
		reward.collected.connect(_on_reward_collected)


func _on_reward_collected(reward_type: String) -> void:
	match reward_type:
		"health":
			player.increase_max_health(25.0)
		"damage":
			player.increase_attack_damage(10.0)
		"speed":
			player.increase_speed(1.5)

	ui.hide_room_cleared()
	for child in get_children():
		if child.is_in_group("reward_pickup"):
			child.queue_free()
