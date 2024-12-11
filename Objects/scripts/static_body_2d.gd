extends StaticBody2D

var death_scene = preload("res://Objects/death_object.tscn")
@onready var tile_map: TileMap = $TileMap
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var collision_shape_2d_2: CollisionShape2D = $CollisionShape2D2

@export var required_force: float = 10

func break_wall():
	if $Area2D.get_overlapping_bodies().size() > 0:
		for body in $Area2D.get_overlapping_bodies():
			if body is Player:
				body.stop_wall_slide()  # Notify the player to stop wall sliding
	collision_shape_2d_2.disabled = true
	HitStopManager.Dash_slow()
	tile_map.queue_free()  # Hide the sprite (or queue free entirely)
	queue_free()  # Optionally remove the node

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and body.dash.is_dashing():  # Check if dashing)
			break_wall()
			spawn()

func spawn():
	var shatter = death_scene.instantiate() as Node2D
	shatter.global_position = global_position
	var shatter_pieces = shatter.get_children()
	for shatter_piece in shatter_pieces:
		shatter_piece = shatter_piece as RigidBody2D
		shatter_piece.linear_velocity = Vector2()
		shatter_piece.linear_velocity = constant_linear_velocity * .5
	get_tree().current_scene.call_deferred("add_child", shatter)
	queue_free()
