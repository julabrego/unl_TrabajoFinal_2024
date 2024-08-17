extends Control

@onready var health_label = $Header/HealthLabel
@onready var lifes_label = $Header/LifesLabel
@onready var score_label = $Header/ScoreLabel
@onready var high_score_label = $Header/HighScoreLabel

func update_health(health: int) -> void:
	health_label.text = str(health)

func update_lifes(lifes: int) -> void:
	lifes_label.text = str(lifes)

func update_score(score: int) -> void:
	score_label.text = str(score)
	
func update_high_score(score: int) -> void:
	high_score_label.text = str(score)
