extends CharacterBody2D

signal fell_into_void

@export var SPEED = 150.0
@export var JUMP_VELOCITY = -300.0

var coyote_time := 0.1
var coyote_timer := 0.0
var is_on_ground := false

var squash_time := 10
var squash_timer := 0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if is_on_floor():
		is_on_ground = true
		coyote_timer = coyote_time
	else:
		if coyote_timer > 0:
			coyote_timer -= delta
		else:
			is_on_ground = false
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_ground:
		velocity.y = JUMP_VELOCITY
		$JumpSfx.play()
	
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("run")
		if direction == -1:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		if squash_timer:
			$AnimatedSprite2D.play("squash")
			squash_timer -= delta
		else:
			$AnimatedSprite2D.play("idle")
		velocity.x = move_toward(velocity.x, 0, SPEED / 2)

	if not is_on_ground:
		if velocity.y > 400:
			$AnimatedSprite2D.play("fall")
			squash_timer = squash_time
		else:
			$AnimatedSprite2D.play("jump")
	
	if $AnimatedSprite2D.global_position[1] > 500:
		fell_into_void.emit()

	move_and_slide()
