extends Node2D

const SHOP_SCENE = preload("res://scenes/shop.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	print("MainMenu ready!")
	$Control/Options/StartButton.grab_focus()
	
	if !OS.has_feature("pc"):
		$Controli/Options/FullscreenButton.hide()
		$Control/Options/QuitButton.hide()

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level%d.tscn" % [Global.currentLevel])

func _on_fullscreen_button_pressed():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_shop_button_pressed():
	var root = get_tree().root
	# Check if ShopLayer already exists
	if root.has_node(Global.SHOP_LAYER_NAME):
		return
	
	# Create CanvasLayer wrapper
	var layer = CanvasLayer.new()
	layer.name = Global.SHOP_LAYER_NAME
	
	# Instance shop as overlay
	var shop = SHOP_SCENE.instantiate()
	shop.name = "ShopOverlay"
	
	# Set pause mode recursively to PROCESS
	Global.set_pause_mode_recursive(shop, Node.PROCESS_MODE_ALWAYS)
	
	# Add shop to layer, layer to root
	layer.add_child(shop)
	root.call_deferred("add_child", layer)
	
	# Pause the tree
	get_tree().paused = true
