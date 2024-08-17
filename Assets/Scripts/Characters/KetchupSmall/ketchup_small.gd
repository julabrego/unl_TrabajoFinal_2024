class_name KetchupSmall
extends CharacterBody3D

@export var SPEED := 6
@export var JUMP_FORCE := 5
@export var GRAVITY := 19.8
@export var target: Node3D = self
@export var health := 30
@export var JUMPS_TO_ATTACK := 2
@export var JUMPS_TO_STOP_ATTACKING := 4
@export var DISTANCE_TRESHOLD := 0.5

var motion := Vector3()
var animation := ""
var is_in_action := false
var is_jumping_to_target := false
var is_receiving_damage := false
var hit_origin : String = ""
var jumps_counter := 0
var current_attack_damage := 5

@onready var sprite : Sprite3D = $Sprite3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var ray_cast : RayCast3D = $RayCast3D
@onready var receiving_damage_timer : Timer = $ReceiveDamageTimer

func _process(delta) -> void:
	_animations(delta)

func _physics_process(delta) -> void:
	if not is_in_action:
		return
		
	if _is_on_ground():
		_handle_jump_direction()
		_jump()

	_move(delta)

func is_attacking() -> bool:
	return is_jumping_to_target
	
func receive_damage(amount: int, origin: String) -> void:
	health -= amount
	is_receiving_damage = true
	receiving_damage_timer.start()
	_reset_jumps_count()

	match origin:
		'LEFT':
			motion.x = 10
		'RIGHT':
			motion.x = -10
		_:
			motion.x = 0

	if health <= 0:
		Global.add_to_score(200)
		queue_free()
	else:
		Global.add_to_score(50)

func get_current_attack_damage() -> int:
	return current_attack_damage

func handle_hit() -> void:
	_stop_movement()
	_reset_jumps_count()

func _reset_jumps_count() -> void:
	jumps_counter = 0
	is_jumping_to_target = false

func _move(delta: float) -> void:
	if is_receiving_damage:
		motion.x *= 0.9
		motion.y = 0
	else:
		_fall(delta)

	velocity = motion
	move_and_slide()

func _is_on_ground() -> bool:
	return ray_cast.is_colliding() and motion.y <= 0

func _handle_jump_direction() -> void:
	var x_distance = abs(position.x - target.position.x)
	var z_distance = abs(position.z - target.position.z)

	if is_jumping_to_target and jumps_counter >= JUMPS_TO_STOP_ATTACKING:
			_stop_following_target()
		
	if (x_distance > DISTANCE_TRESHOLD or z_distance > DISTANCE_TRESHOLD) and not is_jumping_to_target and jumps_counter >= JUMPS_TO_ATTACK:
		is_jumping_to_target = true
		current_attack_damage = 5
		
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

func _on_receive_damage_timer_timeout():
	receiving_damage_timer.stop()
	is_receiving_damage = false
	motion.x = 0
