extends Node2D
class_name Checkpoint
@export var spawnpoint = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var activated = false

func activate():
	GameManager.current_checkpoint = self
	activated = true
	sprite.play("start")

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player and !activated:
		activate()


func _on_animated_sprite_2d_animation_finished() -> void:
	sprite.play("idle")
