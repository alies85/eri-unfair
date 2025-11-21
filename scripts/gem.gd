extends Area2D

signal gem_collected

# Gem magnet settings
var magnet_range = 100.0  # Base range
var magnet_speed = 150.0

func _physics_process(delta):
	# Check if player has gem magnet equipped
	if ShopData.is_equipped("gem_magnet"):
		var player = get_tree().get_first_node_in_group("player")
		if player == null:
			# Try to find player by name
			player = get_node_or_null("/root/Level/Player")
		
		if player:
			var distance = global_position.distance_to(player.global_position)
			if distance < magnet_range and distance > 10:
				# Move gem towards player
				var direction = (player.global_position - global_position).normalized()
				global_position += direction * magnet_speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		gem_collected.emit()
		$CollectedSfx.play()
		hide()

func _on_collected_sfx_finished():
	queue_free()
