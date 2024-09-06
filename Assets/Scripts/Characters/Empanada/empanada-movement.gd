class_name EmpanadaPlayer
extends CharacterBody3D

signal health_has_changed(health)
signal empanada_died()

@export var SPEED := 4
@export var JUMP_FORCE := 10
@export var GRAVITY := 19.8
@export var attack := ["Attack_1", "Attack_2"]

var current_attack_damage := 10
var attack_index := -1
var is_attacking := false
var motion := Vector3()
var animation := ""
var is_control_enabled := true
var health := 100
var is_receiving_damage := false

var is_facing_right = true

@onready var sprite : Sprite3D = $Sprite3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var ray_cast : RayCast3D = $RayCast3D
@onready var receiving_damage_timer : Timer = $ReceiveDamageTimer

func _process(delta) -> void:
	_animations(delta)

func _physics_process(delta) -> void:
	_handle_inputs()
	_move(delta)

func set_health(value: int) -> void:
	Global.player_health = value
	emit_signal("health_has_changed", Global.player_health)

func _handle_inputs() -> void:
	if not is_control_enabled:
		return

	_walk()
	
	if _is_on_ground():
		if not is_attacking and not is_receiving_damage:
			if _player_is_triggering_jump():
				_jump()
			elif _player_is_triggering_attack():
				_punch()
		else:
			_handle_attack_movement()

func _walk() -> void:
	if not is_receiving_damage:
		motion.x = _get_horizontal_input_axis() * SPEED
		motion.z = _get_vertical_input_axis() * SPEED

func _jump() -> void:
	motion.y = JUMP_FORCE

func _move(delta: float) -> void:
	if is_receiving_damage:
		motion.x *= 0.9
		motion.y = 0
	else:
		_fall(delta)
		_handle_attack_movement()

	velocity = motion
	move_and_slide()

func _handle_attack_movement() -> void:
	if is_attacking and not is_receiving_damage:
		_stop_movement()
	
func _animations(delta : float) -> void:
	_flip()
	if is_receiving_damage:
		_set_animation("Receiving_damage")
	elif _is_on_ground():
		if is_attacking:
			_set_animation(attack[attack_index])
		elif motion.x != 0 || motion.z != 0:
			_set_animation("Walking")
		else:
			# _set_animation("walking")
			_set_animation("idle")
	elif motion.y != 0:
		_set_animation("Jumping")

func _fall(delta: float) -> void:
	if not _is_on_ground():
		motion.y -= GRAVITY * delta

func _flip() -> void:
	if motion.x != 0 and not is_receiving_damage:
		$".".scale.x = 1 if motion.x > 0 else -1
		#sprite.flip_h = false if motion.x > 0 else true
		#$Sprite3D/AttackHitbox.position.x = 1 if motion.x > 0 else -1

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
		body.receive_damage(current_attack_damage, origin)

func _on_hit_box_body_entered(body:Node3D):
	if body.is_in_group("Enemy"):
		if body.is_attacking():
			var origin = 'LEFT' if body.position.x < position.x else 'RIGHT'
			receive_damage(body.get_current_attack_damage(), origin)
			body.handle_hit()

func receive_damage(amount: int, origin: String) -> void:
	health -= amount
	is_receiving_damage = true
	emit_signal("health_has_changed", health)
	receiving_damage_timer.start()

	match origin:
		'LEFT':
			motion.x = 10
		'RIGHT':
			motion.x = -10
		_:
			motion.x = 0

	if health <= 0:
		emit_signal("empanada_died")

func _on_receive_damage_timer_timeout():
	receiving_damage_timer.stop()
	is_receiving_damage = false
	motion.x = 0
