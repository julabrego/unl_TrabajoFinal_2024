class_name GameControoler
extends Node3D

@onready var in_game_hud = $InGameHUD
@onready var player = $Empanada
@onready var scene_tree = get_tree()

func _ready():
	Global.connect("score_has_changed", _on_score_has_changed)
	
	if player.has_method("set_health"):
		player.set_health(Global.player_health)
	
	in_game_hud.update_lifes(Global.lifes)
	in_game_hud.update_health(Global.player_health)
	in_game_hud.update_score(Global.score)
	in_game_hud.update_high_score(Global.high_score)

func _victory():
	Global.add_to_score(1000)
	scene_tree.change_scene_to_file("res://Assets/Scenes/UI/main_menu.tscn")

func _game_over():
	scene_tree.change_scene_to_file("res://Assets/Scenes/UI/main_menu.tscn")

func _on_empanada_health_has_changed(health:Variant):
	in_game_hud.update_health(health)

func _on_empanada_empanada_died():
	if Global.lifes > 1:
		Global.change_lifes(Global.lifes - 1)
		scene_tree.reload_current_scene()
	else:
		_game_over()

func _on_end_of_level_area_body_entered(body:Node3D):
	if body.is_in_group("Player"):
		_victory()

func _on_score_has_changed():
	print("Score: " + str(Global.score))
	in_game_hud.update_score(Global.score)