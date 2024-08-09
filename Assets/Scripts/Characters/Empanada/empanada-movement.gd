extends CharacterBody3D

@export var SPEED := 4
@export var JUMP_FORCE := 8
@export var GRAVITY := 19.8
@export var attack := ["Attack_1"]

var attack_index := -1
var timer := 0.0
var attacking := false

var motion := Vector3()
var animation := ""

@onready var sprite : Sprite3D = $Sprite3D
@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var ray_cast : RayCast3D = $RayCast3D
@onready var speed := SPEED

func _process(delta) -> void:
	if not is_on_ground():
		motion.y -= GRAVITY * delta
	
	motion.x = Input.get_axis("ui_left", "ui_right") * speed
	motion.z = Input.get_axis("ui_up", "ui_down") * speed
	
	if Input.is_action_just_pressed("ui_jump") and is_on_ground():
		motion.y = JUMP_FORCE
		attacking = false
	elif Input.is_action_just_pressed("ui_attack") and is_on_ground() and not attacking:
		punch()
	
	_flip()
	_animations(delta)

func _physics_process(delta) -> void:
	velocity = motion
	move_and_slide()

func _flip() -> void:
	if motion.x != 0:
		sprite.flip_h = false if motion.x > 0 else true

func _animations(delta : float) -> void:
	if is_on_ground():
		if (attacking):
			stop_movement()
		elif motion.x != 0 || motion.z != 0:
			set_animation("idle")
		else:
			set_animation("idle")
	#else:
		#_set_animation("Jump")

func stop_movement() -> void:
	motion.x = 0
	motion.z = 0

func is_on_ground() -> bool:
	return ray_cast.is_colliding()
	
func set_animation(anim: String) -> void:
	if animation != anim:
		animation = anim
		animation_player.play(animation)

func punch() -> void:
	attacking = true
	attack_index = (attack_index + 1) % attack.size()
	set_animation(attack[attack_index])

func end_attack() -> void:
	attacking = false
