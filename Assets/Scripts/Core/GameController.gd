class_name GameControoler
extends Node3D

@onready var in_game_hud = $InGameHUD
@onready var player = $Empanada
@onready var scene_tree = get_tree()
@export var player_health := 100
@export var lifes := 3

func _ready():
	if player.has_method("set_health"):
		player.set_health(player_health)

	in_game_hud.update_health(player_health)

func _victory():
	scene_tree.change_scene_to_file("res://Assets/Scenes/UI/main_menu.tscn")

func _game_over():
	scene_tree.change_scene_to_file("res://Assets/Scenes/UI/main_menu.tscn")

func _on_empanada_health_has_changed(health:Variant):
	in_game_hud.update_health(health)

func _on_empanada_empanada_died():
	_game_over()

func _on_end_of_level_area_body_entered(body:Node3D):
	if body.is_in_group("Player"):
		_victory()
