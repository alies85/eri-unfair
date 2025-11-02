extends StaticBody2D

var time = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time += 1
	$AnimatedSprite2D.position += Vector2(0, sin(time) * 2)
	$AnimatedSprite2D2.position += Vector2(0, sin(time) * 2)
	$AnimatedSprite2D3.position += Vector2(0, sin(time) * 2)
	$AnimatedSprite2D4.position += Vector2(0, sin(time) * 2)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		set_process(true)
		$Timer.start(0.7)

func _on_timer_timeout() -> void:
	if is_processing():
		set_process(false)
		$GPUParticles2D.emitting = true
		$Area2D.queue_free()
		$CollisionShape2D.queue_free()
		$AnimatedSprite2D.queue_free()
		$AnimatedSprite2D2.queue_free()
		$AnimatedSprite2D3.queue_free()
		$AnimatedSprite2D4.queue_free()
		$Timer.start(1.2)
	else:
		queue_free()
