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

# Power-up variables
var has_double_jump = false
var jump_count = 0
var has_shield = false
var shield_active = false

func _ready():
	apply_powerups()
	apply_cosmetics()

func apply_powerups():
	# Apply speed boost only if equipped
	if ShopData.is_equipped("speed_boost"):
		SPEED = 225.0  # 150 * 1.5
	else:
		SPEED = 150.0
	
	# Apply jump boost only if equipped
	if ShopData.is_equipped("jump_boost"):
		JUMP_VELOCITY = -390.0  # -300 * 1.3
	else:
		JUMP_VELOCITY = -300.0
	
	# Check double jump only if equipped
	has_double_jump = ShopData.is_equipped("double_jump")
	
	# Check shield - regenerate at start of each level only if equipped
	has_shield = ShopData.is_equipped("shield")
	if has_shield:
		shield_active = true  # Reset shield protection for each level

func apply_cosmetics():
	# Apply skin colors based on equipped skin
	if ShopData.is_equipped("red_skin"):
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.modulate = Color(1.5, 0.5, 0.5)
	elif ShopData.is_equipped("blue_skin"):
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.modulate = Color(0.5, 0.5, 1.5)
	elif ShopData.is_equipped("green_skin"):
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.modulate = Color(0.5, 1.5, 0.5)
	else:
		# Default color
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.modulate = Color(1.0, 1.0, 1.0)
	
	# Toggle particle effects based on equipped state
	if has_node("RainbowTrail"):
		$RainbowTrail.emitting = ShopData.is_equipped("rainbow_trail")
	
	if has_node("DiamondTrail"):
		$DiamondTrail.emitting = ShopData.is_equipped("diamond_trail")
	
	if has_node("StarParticles"):
		$StarParticles.emitting = ShopData.is_equipped("star_particles")

func _physics_process(delta):
	if is_on_floor():
		is_on_ground = true
		coyote_timer = coyote_time
		jump_count = 0  # Reset jump count when on ground
	else:
		if coyote_timer > 0:
			coyote_timer -= delta
		else:
			is_on_ground = false
	
	if not is_on_floor():
		# Apply slow motion if equipped (affects gravity)
		var time_scale = 1.0
		if ShopData.is_equipped("slow_motion"):
			time_scale = 0.7
		velocity.y += gravity * delta * time_scale
	
	# Handle jumping with double jump support
	if Input.is_action_just_pressed("jump"):
		if is_on_ground:
			velocity.y = JUMP_VELOCITY
			jump_count = 1
			$JumpSfx.play()
		elif has_double_jump and jump_count < 2:
			velocity.y = JUMP_VELOCITY
			jump_count = 2
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


func _on_gravity_change() -> void:
	JUMP_VELOCITY = -200
	gravity = 350
