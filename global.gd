extends Node

const SHOP_LAYER_NAME = "ShopLayer"
const SHOP_SCENE = preload("res://scenes/shop.tscn")

var score = 200
var currentLevel = 1
var lvl3score = 0

func _ready():
	print_debug("global ready!")
	print_debug(score)

# Helper function to recursively set pause_mode on a node and all its children
func set_pause_mode_recursive(node: Node, mode: Node.ProcessMode):
	node.process_mode = mode
	for child in node.get_children():
		set_pause_mode_recursive(child, mode)

func _input(event):
	if event.is_action_pressed("return_to_main_menu"):
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
	
	if event.is_action_pressed("open_shop"):
		var root = get_tree().root
		# Check if ShopLayer already exists
		if root.has_node(SHOP_LAYER_NAME):
			var layer = root.get_node(SHOP_LAYER_NAME)
			layer.queue_free()
			get_tree().paused = false
			return
		
		# Create CanvasLayer wrapper
		var layer = CanvasLayer.new()
		layer.name = SHOP_LAYER_NAME
		
		# Instance shop scene
		var shop = SHOP_SCENE.instantiate()
		shop.name = "ShopOverlay"
		
		# Set pause mode recursively to PROCESS
		set_pause_mode_recursive(shop, Node.PROCESS_MODE_ALWAYS)
		
		# Add shop to layer, layer to root
		layer.add_child(shop)
		root.call_deferred("add_child", layer)
		
		# Pause the tree
		get_tree().paused = true
