extends Area2D

signal trap_activated

func _on_body_entered(body):
	if body.name == "Player":
		trap_activated.emit()
		$CollectedSfx.play()

func _on_collected_sfx_finished():
	queue_free()
