class_name KetchupSmall
extends CharacterBody3D

@export var SPEED := 6
@export var JUMP_FORCE := 5
@export var GRAVITY := 19.8
@export var target: Node3D = self

var motion := Vector3()
var animation := ""
var is_in_action := false
var is_jumping_to_target := false
var is_able_to_jump_to_target := false
var jumps_counter := 0

@onready var sprite : Sprite3D = $Sprite3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var ray_cast : RayCast3D = $RayCast3D
@onready var timer : Timer = $IdleTimer

func _process(delta) -> void:
	_animations(delta)

func _physics_process(delta) -> void:
	if not is_in_action:
		return
		
	if _is_on_ground():
		_handle_jump_direction()
		_jump()

	_move(delta)

func _move(delta: float) -> void:
	velocity = motion
	_fall(delta)
	move_and_slide()

func _is_on_ground() -> bool:
	return ray_cast.is_colliding() and motion.y <= 0

func _handle_jump_direction() -> void:
	var x_distance = abs(position.x - target.position.x)
	var z_distance = abs(position.z - target.position.z)

	if is_jumping_to_target and jumps_counter >= 5:
			_stop_following_target()
		
	if (x_distance > 2 or z_distance > 2) and not is_jumping_to_target and jumps_counter >= 3:
		is_jumping_to_target = true
		
	if is_jumping_to_target:
		_follow_target()
		
func _jump() -> void:
	motion.y = JUMP_FORCE
	jumps_counter += 1

func _fall(delta: float) -> void:
	if not _is_on_ground():
		motion.y -= GRAVITY * delta

func _follow_target() -> void:
	_point_to(target.position)

func _stop_following_target() -> void:
	_point_to(position)
	is_jumping_to_target = false
	jumps_counter = 0

func _point_to(target: Vector3):
	motion.x = position.direction_to(target).x * SPEED
	motion.z = position.direction_to(target).z * SPEED

func _animations(delta : float) -> void:
	_flip()
	pass

func _flip() -> void:
	if motion.x != 0:
		sprite.flip_h = false if motion.x > 0 else true
	
func _stop_movement() -> void:
	motion.x = 0
	motion.z = 0

func _on_visible_area_body_entered(body):
	if body.is_in_group("Player") and not is_in_action:
		is_in_action = true

func _on_idle_timer_timeout():
	is_able_to_jump_to_target = true