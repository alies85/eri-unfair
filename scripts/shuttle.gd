extends StaticBody2D

var time = 1

var vibrating = false

var move_up = false
var move_duration = 3.0
var move_speed = 80
var time_passed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if move_up:
		time_passed += delta
		if time_passed <= move_duration:
			global_position.y -= move_speed * delta
		else:
			move_up = false
	
	if vibrating:
		time += 0.7
		var vibrate = Vector2(sin(time), sin(time))
		for child in self.get_children():
			if child is AnimatedSprite2D:
				child.position += vibrate
	$GPUParticles2D.emitting = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Area2D.queue_free()
		set_process(true)
		vibrating = true
		body.global_position = $CollisionShape2D3.global_position+Vector2(0, 10)
		$Timer.start(2)

func _on_timer_timeout() -> void:
	vibrating = false
	move_up = true
	$GPUParticles2D.emitting = false
