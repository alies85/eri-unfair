extends Area2D

@export var jump_force: float = 800.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("idle")

func _on_body_entered(body: Node) -> void:
	if body is CharacterBody2D and body.name == "Player":
		body.velocity.y = -jump_force
		sprite.play("bounce")

func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.play("idle")
