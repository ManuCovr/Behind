extends CharacterBody2D


@onready var chase_timer: Timer = $ChaseTimer
@onready var sprite: AnimatedSprite2D = $Marker2D/AnimatedSprite2D
@onready var detection_area: Area2D = $detection_area
@onready var marker_2d: Marker2D = $Marker2D
@onready var collision: CollisionShape2D = $CollisionShape2D2
const Dash = preload("res://scripts/dash.gd")

@export var speed = 40
@export var gravity = 500
@export var chase_accel = 500
var player_chase = false
var player : Node2D = null
var hp = 10
var dead = false


func _physics_process(delta: float) -> void:
	# Apply gravity
	if !dead:
		if !is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity.y = 0  # Reset vertical velocity when on the floor

	# Handle chasing the player
		if player_chase and player:
		# Calculate horizontal direction to the player
			sprite.play("walk")
			var direction_to_player = sign(player.position.x - position.x)
				# Flip the sprite based on direction
			if direction_to_player > 0:
				marker_2d.scale.x = 1  # Facing right
			elif direction_to_player < 0:
				marker_2d.scale.x = -1  # Facing left
			velocity.x = move_toward(velocity.x, direction_to_player * speed, chase_accel * delta)
		else:
		# Stop moving when not chasing
			velocity.x = move_toward(velocity.x, 0, chase_accel * delta)
		if hp <= 0:
			die()
		
	# Move the enem
		move_and_slide()

func _on_detection_area_body_entered(body: Node2D) -> void:
	# Start chasing the player if detected
	if body.name == "Player":  # Adjust to match the player's node name
		player = body
		player_chase = true
		chase_timer.stop()
	
func _on_detection_area_body_exited(body: Node2D) -> void:
	# Start the chase timer when the player exits the detection area
	if body.name == "Player":
		chase_timer.start()

func _on_chase_timer_timeout() -> void:
	if not is_instance_valid(player):  # If the player is no longer valid
		player = null
		player_chase = false
	elif !player_in_detection_area():  # If the player is not in the detection area
		player = null
		player_chase = false

func player_in_detection_area() -> bool:
	var bodies = detection_area.get_overlapping_bodies()
	return player in bodies


func _on_hurtbox_area_entered(hitbox):
	if dead:
		return
	else:  # Confirm it's an instance of the 'hitbox' class
		var base_damage = hitbox.damage  # Access the damage property
		hp -= base_damage
		# Check if HP is depleted
		if hp <= 0:
			die()

func die():
	collision.set_deferred("disabled", true)
	FrameFreeze(0.05, 0.5)
	dead = true
	velocity = Vector2.ZERO
	sprite.play("death")
	if is_instance_valid(player) and player.has_method("reset_dash"):
		player.reset_dash()  # Call reset_dash function on the player


func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "death":
		queue_free()

func FrameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	var timer = get_tree().create_timer(timeScale * duration)
	await timer.timeout
	Engine.time_scale = 1 
