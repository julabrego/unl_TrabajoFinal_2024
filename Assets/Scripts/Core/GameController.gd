class_name GameControoler
extends Node3D

@onready var in_game_hud : Control
@onready var player : CharacterBody3D

@export var player_health := 100

func _ready():
	in_game_hud = $InGameHUD
	player = $Empanada

	if player.has_method("set_health"):
		player.set_health(player_health)

	in_game_hud.update_health(player_health)

func _on_empanada_health_has_changed(health:Variant):
	if in_game_hud.has_method("update_health"):
		in_game_hud.update_health(health)