extends Node

signal score_has_changed

@export var lifes := 3
@export var player_health := 100
@export var high_score := 0
@export var score := 0

var scene_tree

func _ready():
	scene_tree = get_tree()
	scene_tree.change_scene_to_file("res://Assets/Scenes/UI/main_menu.tscn")

func change_health(value:int):
	player_health = value

func add_to_score(value:int):
	score += value
	if high_score < score:
		high_score = score
	emit_signal("score_has_changed")

func change_lifes(value:int):
	lifes = value

