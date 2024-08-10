class_name KetchupSmall
extends CharacterBody3D

@export var SPEED := 6
@export var JUMP_FORCE := 5
@export var GRAVITY := 19.8
@export var target: Node3D = self

var attacking := false

var motion := Vector3()
var animation := ""

@onready var sprite : Sprite3D = $Sprite3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var ray_cast : RayCast3D = $RayCast3D
@onready var timer : Timer = $IdleTimer

var speed := SPEED
var is_in_action := false
var is_jumping_to_target := false
var is_able_to_jump_to_target := false

var jumps_counter := 0

func _process(delta) -> void:
	_flip()
	_animations(delta)

func _physics_process(delta) -> void:
	if not is_in_action:
		return
		
	velocity = motion
	
	var x_distance = abs(position.x - target.position.x)
	var z_distance = abs(position.z - target.position.z)

	if not is_on_ground():
		motion.y -= GRAVITY * delta
		
	if is_on_ground():
		motion.y = JUMP_FORCE
		jumps_counter += 1
		
		if is_jumping_to_target and jumps_counter > 5:
			point_to(self.position)
			is_jumping_to_target = false
			jumps_counter = 1
		
		if (x_distance > 2 or z_distance > 2) and not is_jumping_to_target and jumps_counter > 3:
			is_jumping_to_target = true
			
		if is_jumping_to_target:
			point_to(target.position)

	print(jumps_counter)
	move_and_slide()

func _flip() -> void:
	if motion.x != 0:
		sprite.flip_h = false if motion.x > 0 else true

func _animations(delta : float) -> void:
	pass
	
func point_to(target: Vector3):
	motion.x = position.direction_to(target).x * speed
	motion.z = position.direction_to(target).z * speed
	
func stop_movement() -> void:
	motion.x = 0
	motion.z = 0

func is_on_ground() -> bool:
	return ray_cast.is_colliding() and motion.y <= 0
	
func set_animation(anim: String) -> void:
	if animation != anim:
		animation = anim
		animation_player.play(animation)

func _on_visible_area_body_entered(body):
	if body.is_in_group("Player") and not is_in_action:
		is_in_action = true

func _on_idle_timer_timeout():
	is_able_to_jump_to_target = true
