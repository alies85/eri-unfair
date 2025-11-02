extends Area2D

signal gem_collected

func _on_body_entered(body):
	if body.name == "Player":
		gem_collected.emit()
		$CollectedSfx.play()
		hide()

func _on_collected_sfx_finished():
	queue_free()
