extends Node

var score = 0
var currentLevel = 1
var username = ""
var lvl3score = 0
var healthCount = 100

func _ready():
	print_debug("global ready!")
	print_debug(score)

func _input(event):
	if event.is_action_pressed("return_to_main_menu"):
		get_tree().change_scene_to_file("res://scenes/mainMenu.tscn")
