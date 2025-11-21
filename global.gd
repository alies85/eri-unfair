extends Node

var score = 0
var currentLevel = 1
var lvl3score = 0

func _ready():
	print_debug("global ready!")
	print_debug(score)

func _input(event):
	if event.is_action_pressed("return_to_main_menu"):
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
	
	if event.is_action_pressed("open_shop"):
		var root = get_tree().current_scene
		if root.has_node("ShopOverlay"):
			root.get_node("ShopOverlay").queue_free()
			get_tree().paused = false
			return
		var shop_scene = preload("res://scenes/shop.tscn")
		var shop = shop_scene.instantiate()
		shop.name = "ShopOverlay"
		shop.set_z_index(100)
		shop.process_mode = Node.PROCESS_MODE_ALWAYS
		root.call_deferred("add_child", shop)
		get_tree().paused = true
