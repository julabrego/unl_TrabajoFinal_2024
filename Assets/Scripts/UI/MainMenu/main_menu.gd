extends Control

@onready var scene_tree = get_tree()

func _on_button_jugar_pressed():
	scene_tree.change_scene_to_file("res://Assets/Scenes/Scenarios/world_1.tscn")

