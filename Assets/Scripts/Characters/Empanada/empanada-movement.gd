extends CharacterBody3D

@export var SPEED := 3
@export var JUMP_FORCE := 8
@export var GRAVITY := 19.8
@export var attack := ["Attack_1", "Attack_2"]

var attack_index := -1
var timer := 0.5
var cooldown := 0.5
var attacking := false

var motion := Vector3()

@onready var sprite : Sprite3D = $Sprite3D
@onready var speed := SPEED

func _process(delta) -> void:
	if not is_on_ground():
		motion.y -= GRAVITY * delta
	
	motion.x = Input.get_axis("ui_left", "ui_right") * speed
	motion.z = Input.get_axis("ui_up", "ui_down") * speed
	
	if Input.is_action_just_pressed("ui_jump") and is_on_ground():
		motion.y = JUMP_FORCE
	elif Input.is_action_just_pressed("ui_attack") and is_on_ground() and timer > 0.3:
		attacking = true
		timer = 0
		attack_index = (attack_index + 1) % attack.size()
	
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
			_stop_movement()
			timer += delta
			if(timer >= cooldown):
				attacking = false
				attack_index = -1
		#elif motion.x != 0 || motion.z != 0:
			#_set_animation("Walk")
		#else:
			#_set_animation("Idle")
	#else:
		#_set_animation("Jump")

func _stop_movement() -> void:
	motion.x = 0
	motion.z = 0

func is_on_ground() -> bool:
	return $RayCast3D.is_colliding()
