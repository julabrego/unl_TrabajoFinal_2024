extends Control

@onready var scene_tree = get_tree()

func _ready():
	$VBoxContainer/HighScore.text = 'High score: ' + str(Global.high_score)

func _on_button_jugar_pressed():
	Global.score = 0
	scene_tree.change_scene_to_file("res://Assets/Scenes/Scenarios/world_1.tscn")

