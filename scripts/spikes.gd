extends Node2D
@onready var node_2d: GPUParticles2D = $Node2D
@onready var timer: Timer = $Timer
@onready var camera_2d: Camera2D = $"../Camera2D"


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		var player = area.get_parent()
		
		# Disable the player's movement and interactions
		player.set_process(false)  # Stops the player's `_process` and `_physics_process`
		player.set_physics_process(false)  # Stops physics-related actions
		if player.has_node("CollisionShape2D"):
			player.get_node("CollisionShape2D").disabled = true  # Disable collisions
		
		# Hide the player's visuals
		player.hide()
	
		# Start trap effect
		node_2d.emitting = true
		timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
