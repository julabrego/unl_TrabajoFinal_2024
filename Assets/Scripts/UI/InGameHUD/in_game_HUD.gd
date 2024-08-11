extends Control

@onready var health_label = $Header/HealthLabel

func update_health(health: int) -> void:
	health_label.text = str(health)
