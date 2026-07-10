extends Area3D

signal collected(reward_type: String)

@export var reward_type: String = "health"

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	add_to_group("reward_pickup")
	body_entered.connect(_on_body_entered)

	var material := StandardMaterial3D.new()
	match reward_type:
		"health":
			material.albedo_color = Color(0.2, 0.9, 0.3)
		"damage":
			material.albedo_color = Color(0.9, 0.3, 0.2)
		"speed":
			material.albedo_color = Color(0.3, 0.5, 0.9)
	mesh_instance.set_surface_override_material(0, material)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		collected.emit(reward_type)
		queue_free()
