extends StaticBody2D

var time = 1

var vibrating = false

signal finished(level)

@export var levelMusic: AudioStreamPlayer

@export var next_level: int

@export var idle_duration = 2.0
var idle_passed = 0.0

var move_up = false
@export var move_duration = 3.0
@export var move_speed = 80
var time_passed = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_process(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$GPUParticles2D.emitting = true
	if levelMusic:
		levelMusic.volume_db -= 0.1
	
	if move_up:
		time_passed += delta
		if time_passed <= move_duration:
			global_position.y -= move_speed * delta
		else:
			move_up = false
			$vfx.stop()
			$GPUParticles2D.emitting = false
			$CollisionShape2D4.queue_free()
			if (next_level > 0):
				finished.emit(next_level)
			set_process(false)
	
	if vibrating:
		idle_passed += delta
		if idle_passed > idle_duration:
			vibrating = false
			move_up = true
			
		time += 0.7
		var vibrate = Vector2(sin(time), sin(time))
		for child in self.get_children():
			if child is AnimatedSprite2D:
				child.position += vibrate

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		$Area2D.queue_free()
		$vfx.play()
		set_process(true)
		vibrating = true
		body.global_position = $CollisionShape2D3.global_position+Vector2(0, 10)
