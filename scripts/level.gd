extends Node2D

signal gravityChange

@export var levelNO = 0

func _ready():
	if levelNO >= 6:
		gravityChange.emit()
	
	$HUD.level(levelNO)
	Global.currentLevel = levelNO
	
	$HUD.score(Global.score)
	
	if levelNO == 2:
		$Door.get_child(0).disabled = true

	for gem in $Gems.get_children():
		gem.gem_collected.connect(_on_gem_collected)
		
	for trap in $Traps.get_children():
		trap.trap_activated.connect(_on_trap_activated)

func death():
	Global.score = 0
	Global.lvl3score = 0
	get_tree().change_scene_to_file("res://scenes/deathMenu.tscn")

func _on_gem_collected():
	Global.score += 1
	if levelNO == 3:
		Global.lvl3score += 1
		if Global.lvl3score >= 11:
			death()
	$HUD.score(Global.score)

func _on_trap_activated():#/////////////////////
	death()

func _on_player_fell_into_void() -> void:
	death()

func _on_door_player_entered(level):
	get_tree().change_scene_to_file("res://scenes/levels/level%d.tscn" % [level])

func _on_door_2_player_entered(level: Variant) -> void:
	death()

func _on_spike_entered() -> void:
	death()

func _input(event):
	if event.is_action_pressed("reset_level"):
		get_tree().reload_current_scene.call_deferred()
		Global.score = 0
		$HUD.score(Global.score)

func _on_timer_timeout() -> void:
	$Door.visible = true
	$Door.get_child(0).disabled = false


func _on_door_finish_player_entered(level: Variant) -> void:
	get_tree().change_scene_to_file("res://scenes/finishMenu.tscn")


func _on_gem_6_gem_collected() -> void:
	Global.lvl3score -= 1
	get_tree().change_scene_to_file("res://scenes/levels/level4.tscn")
