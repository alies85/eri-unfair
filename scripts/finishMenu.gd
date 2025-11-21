extends Node2D

func generate_hash(solver_group_id: String, private_key: String) -> String:
	var combined := solver_group_id + ":" + private_key
	var raw := combined.sha256_buffer()
	var b64 := Marshalls.raw_to_base64(raw)
	b64 = b64.replace("+", "-").replace("/", "_").replace("=", "")
	if b64.length() >= 10:
		return b64.substr(0, 10)
	else:
		return b64 + "-".repeat(10 - b64.length())

# Called when the node enters the scene tree for the first time.
func _ready():
	print("FinishMenu ready!")
	
	$ResCode.text = generate_hash("", "1KW7WRNH")
	
	if !OS.has_feature("pc"):
		$Options/FullscreenButton.hide()
		$Options/QuitButton.hide()

func _on_start_button_pressed():#//////////////
	get_tree().change_scene_to_file("res://scenes/levels/level%d.tscn" % [Global.currentLevel])

func _on_fullscreen_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_quit_button_pressed():
	get_tree().quit()
