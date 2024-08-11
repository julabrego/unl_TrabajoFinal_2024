class_name EmpanadaPlayer
extends CharacterBody3D

signal health_has_changed(health)

@export var SPEED := 4
@export var JUMP_FORCE := 8
@export var GRAVITY := 19.8
@export var attack := ["Attack_1"]

var attack_index := -1
var is_attacking := false
var motion := Vector3()
var animation := ""
var is_control_enabled := true
var health := 100

@onready var sprite : Sprite3D = $Sprite3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var ray_cast : RayCast3D = $RayCast3D

func _process(delta) -> void:
	_animations(delta)

func _physics_process(delta) -> void:
	_handle_inputs()
	_move(delta)

func set_health(value: int) -> void:
	health = value
	emit_signal("health_has_changed", health)

func _handle_inputs() -> void:
	if not is_control_enabled:
		return

	_walk()
	
	if _is_on_ground():
		if not is_attacking:
			if _player_is_triggering_jump():
				_jump()
			elif _player_is_triggering_attack():
				_punch()
		else:
			_handle_attack_movement()

func _walk() -> void:
	motion.x = _get_horizontal_input_axis() * SPEED
	motion.z = _get_vertical_input_axis() * SPEED

func _jump() -> void:
	motion.y = JUMP_FORCE

func _move(delta: float) -> void:
	velocity = motion
	_fall(delta)
	_handle_attack_movement()
	move_and_slide()

func _handle_attack_movement() -> void:
	if is_attacking:
		_stop_movement()
	
func _animations(delta : float) -> void:
	_flip()
	if _is_on_ground():
		if is_attacking:
			_set_animation(attack[attack_index])
		elif motion.x != 0 || motion.z != 0:
			# _set_animation("walking")
			_set_animation("idle") 
		else:
			# _set_animation("walking")
			_set_animation("idle")
		# _set_animation("jumping")
		# _set_animation("falling")


func _fall(delta: float) -> void:
	if not _is_on_ground():
		motion.y -= GRAVITY * delta

func _flip() -> void:
	if motion.x != 0:
		sprite.flip_h = false if motion.x > 0 else true	
		$Sprite3D/AttackHitbox.position.x = 1 if motion.x > 0 else -1

func _stop_movement() -> void:
	motion.x = 0
	motion.z = 0

func _is_on_ground() -> bool:
	return ray_cast.is_colliding() and motion.y <= 0
	
func _punch() -> void:
	is_attacking = true
	attack_index = (attack_index + 1) % attack.size()

func end_attack() -> void:
	is_attacking = false

func _set_animation(anim: String) -> void:
	if animation != anim:
		animation = anim
		animation_player.play(animation)

func _player_is_triggering_jump() -> bool:
	return Input.is_action_just_pressed("ui_jump")

func _player_is_triggering_attack() -> bool:
	return Input.is_action_just_pressed("ui_attack")

func _get_horizontal_input_axis() -> float:
	return Input.get_axis("ui_left", "ui_right")

func _get_vertical_input_axis() -> float:
	return Input.get_axis("ui_up", "ui_down")

func _on_attack_hitbox_body_entered(body:Node3D):
	if body.is_in_group("Enemy"):
		var origin = 'LEFT' if position.x < body.position.x else 'RIGHT'
		body.receive_damage(10, origin)

func _on_hit_box_body_entered(body:Node3D):
	if body.is_in_group("Enemy"):
		var origin = 'LEFT' if body.position.x < position.x else 'RIGHT'
		receive_damage(body.get_current_attack_damage(), origin)

func receive_damage(amount: int, origin: String) -> void:
	health -= amount
	emit_signal("health_has_changed", health)
	
