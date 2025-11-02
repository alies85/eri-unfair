extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	$DeathSfx.play()
	
	$Options/RestartButton.grab_focus()
	
	if !OS.has_feature("pc"):
		$Options/FullscreenButton.hide()
		$Options/QuitButton.hide()

func _on_restart_button_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level%d.tscn" % [Global.currentLevel])

func _on_fullscreen_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_quit_button_pressed():
	get_tree().quit()
