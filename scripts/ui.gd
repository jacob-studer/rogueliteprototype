extends CanvasLayer

@onready var health_bar: ProgressBar = $HealthBar
@onready var health_label: Label = $HealthLabel
@onready var enemy_count_label: Label = $EnemyCountLabel
@onready var room_cleared_label: Label = $RoomClearedLabel
@onready var death_label: Label = $DeathLabel


func set_health(current: float, max_value: float) -> void:
	health_bar.max_value = max_value
	health_bar.value = current
	health_label.text = "%d / %d" % [int(current), int(max_value)]


func set_enemy_count(count: int) -> void:
	enemy_count_label.text = "Enemies: %d" % count


func show_room_cleared() -> void:
	room_cleared_label.visible = true


func hide_room_cleared() -> void:
	room_cleared_label.visible = false


func show_death_screen() -> void:
	death_label.visible = true
