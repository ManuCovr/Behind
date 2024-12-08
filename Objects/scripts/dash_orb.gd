extends Area2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var dash_orb: Area2D = $"."
@onready var timer: Timer = $Timer
@onready var node_2d: GPUParticles2D = $Node2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D




func _on_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		var player = area.get_parent() as Player
		if not player.dash.can_dash:
			player.dash.can_dash = true  # Reset the player's dash
		# Handle visual effects and remove orb
		collision_shape_2d.queue_free()
		sprite.queue_free()
		node_2d.emitting = true
		timer.start()
func _on_timer_timeout() -> void:
	queue_free()
