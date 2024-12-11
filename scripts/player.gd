extends CharacterBody2D
class_name Player


@export var jump_buffer_buffer : float = 0.1 
@export var RunSpeed : float = 120.0
@export var JUMP_VELOCITY : float = -220.0
@export var gravity_multiplyer : float = 1.5
@export var dash_delay : float = 0.7
@export var wall_slide_speed : float = 1400
@export var wall_side_grab_speed = 100
@export var camera_limit_left = -150
@export var camera_limit_right = 200
@export var cam = 1000

@onready var ghost_effect_2: GPUParticles2D = $GhostEffect2
@onready var dash_sound: AudioStreamPlayer2D = $dashSound

@onready var ghost_effect: GPUParticles2D = $GhostEffect
@onready var dash_timer: Timer = $Dash/DashTimer
@onready var dash_particles: GPUParticles2D = $dash_particles
@export var dash_sprite : PackedScene
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var marker_2d: Marker2D = $Marker2D
@onready var sprite: AnimatedSprite2D = $Marker2D/AnimatedSprite2D
@onready var second_one: AnimatedSprite2D = $Marker2D/SecondOne
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var dash: Node2D = $Dash
@onready var camera_2d: Camera2D = $"../Camera2D"



var playing_jump_start: bool = false  # Lock to prioritize jump_start animation
var can_jump : bool = true
var has_wall_jumped : bool = false
var doWallJump : bool = false
var jump_buffer : bool = false
var animation_locked: bool = false
var direction : Vector2 = Vector2.ZERO
var was_on_air : bool = false
var can_dust : bool = true
var dash_direction = Vector2.ZERO
var on_wall = false
var wall_direction = 0
var wall_grab = false

const PUSH = 300
signal change_camera_pos
const dashspeed = 420
const dashlenght = 0.2
const dashspeed_ver = 250


func _ready() -> void:
	GameManager.player = self

func _physics_process(delta: float) -> void:
	if is_on_floor():
		if was_on_air:
			was_on_air = false
	else:
		velocity += get_gravity() * delta * gravity_multiplyer
		was_on_air = true
	# Handle Jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_wall_only() and !has_wall_jumped:
			wall_jump()
		elif can_jump and (is_on_floor() || !coyote_timer.is_stopped()):
			jump()
		elif !is_on_floor() and was_on_air and !jump_buffer:
			# Activate jump buffer if in the air
			jump_buffer = true
			jump_buffer_timer.start()
	
	# Wall Slide
	if is_on_wall_only() and !Input.is_action_just_pressed("jump") and !doWallJump and !dash.is_dashing():
		wall_slide(delta)
	direction.x = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
	#direction.y = sign(Input.get_action_strength("down") - Input.get_action_strength("up"))
	if Input.is_action_just_pressed("dash") and !dash.is_dashing() and dash.can_dash:
	# Get directional input
		dash_sound.play()
		var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
		)

	# Determine dash direction
		if input_direction.x != 0:
			dash_direction = Vector2(input_direction.x, 0)  # Horizontal dash
		elif input_direction.y != 0:
			dash_direction = Vector2(0, input_direction.y)  # Vertical dash
		else:
			dash_direction = Vector2(marker_2d.scale.x, 0)  # Default to facing direction

	# Set animation and lock it
		if abs(dash_direction.y) > abs(dash_direction.x):  # Vertical dash
			playing_jump_start = true
			second_one.play("jump_start")
			second_one.scale = Vector2(0.7, 1.3)
		else:  # Horizontal dash
			second_one.play("dash")
			second_one.scale = Vector2(1.5, 0.7)

	# Emit particles
		ghost_effect_2.emitting = abs(dash_direction.y) > abs(dash_direction.x)
		dash_particles.emitting = not ghost_effect_2.emitting
		ghost_effect.emitting = not ghost_effect_2.emitting

	# Start dash
		dash.start_dash(dashlenght)
		dash.can_dash = false
		camera_2d.add_trauma(0.25)


# Handle dash behavior when active
	if dash.is_dashing():
		if abs(dash_direction.y) > abs(dash_direction.x):
		# Primarily vertical dash -> use vertical speed
			velocity = dash_direction * dashspeed_ver
		else:
		# Horizontal dash -> use horizontal speed
			velocity = dash_direction * dashspeed



	else:
		direction.x = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
		dash_particles.emitting = false
		ghost_effect.emitting = false
		ghost_effect_2.emitting = false
		if direction.x != 0 and !doWallJump:
			velocity.x = direction.x * RunSpeed
		elif !doWallJump:
			velocity.x = 0
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
	
	# Debugging the collision object
		if collision == null:
			print("No collision data for index: ", i)
		continue
	
		if collision.collider == null:
			print("No collider found for collision at index: ", i)
		continue

	# Check if the collider is a MovableBlock
		if collision.collider is MovableBlock:
			print("Applying impulse to MovableBlock at index: ", i)
			collision.collider.apply_central_impulse(-collision.normal * PUSH)
		else:
			print("Collider is not a MovableBlock. It is: ", collision.collider.get_class())


# Move and Slide
	var was_on_floor = is_on_floor()

	
	#move_camera()
	move_and_slide()
	update_animation()
	update_facing_direction()
	second_one.scale.x = move_toward(second_one.scale.x, 1, 1 * delta)
	second_one.scale.y = move_toward(second_one.scale.y, 1, 1 * delta)
	# Touched Ground
	if !was_on_floor and is_on_floor():
		reset_wall_jump()
		can_jump = true
		coyote_timer.stop()
		if jump_buffer:
			reset_jump_buffer()
			jump()
	# Left the Wall
	if !is_on_wall_only():
		has_wall_jumped = false
	if was_on_floor and !is_on_floor():
		coyote_timer.start()
	if position.y <= 0:
		die()

func _on_enemy_killed():
	# Reset dash and allow a small window to dash again
	dash.can_dash = true  # Allow re-dash
	dash_particles.emitting = false
	ghost_effect.emitting = false  # Stop dash particles

# Wall Jump Implementation
func wall_jump():
	# Get the wall normal to determine the jump direction
	var wall_direction = get_wall_normal()
	velocity.x = wall_direction.x * RunSpeed * 1.5  # Push away from the wall
	velocity.y = JUMP_VELOCITY  # Boost upward
	has_wall_jumped = true  # Prevent multiple wall jumps
	can_jump = false
	doWallJump = true
	playing_jump_start = true  # Lock animation to jump_start
	$WallJumpTimer.start()
	sprite.visible = false
	second_one.visible = true
	second_one.play("jump_start")  # Play wall jump animation


# Wall Slide Implementation
func wall_slide(delta: float):
	velocity.y = min(velocity.y, wall_slide_speed * delta)  # Apply slide speed cap
	sprite.visible = false
	second_one.visible = true
	second_one.play("wallslide")  # Play wall slide animation if it exists

# Reset Wall Jump State
func reset_wall_jump():
	doWallJump = false
	has_wall_jumped = false
	playing_jump_start = false
	update_animation()

func jump():
	if can_jump and (is_on_floor() || !coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		sprite.visible = false
		second_one.visible = true
		second_one.play("jump_start")
		second_one.scale = Vector2(0.7, 1.3)
		playing_jump_start = true
		can_jump = false
		reset_jump_buffer()
	elif was_on_air and jump_buffer:
		velocity.y = JUMP_VELOCITY
		sprite.visible = false
		second_one.visible = true
		second_one.play("jump_start")
		playing_jump_start = true
		can_jump = false
		reset_jump_buffer()

func reset_jump_buffer():
	jump_buffer = false
	jump_buffer_timer.stop()
	
func _on_wall_jump_timer_timeout() -> void:
	reset_wall_jump()
	playing_jump_start = false
	
func _on_jump_buffer_timer_timeout():
	reset_jump_buffer()

func update_animation():
	# Prioritize locked animations
	if playing_jump_start:
		# Ensure "jump_start" finishes playing before transitioning
		if second_one.animation == "jump_start" and !second_one.is_playing():
			playing_jump_start = false  # Unlock animation
		else:
			return  # Prevent overriding during dash/jump_start

	# Handle dash animation
	if dash.is_dashing():
		sprite.visible = false
		second_one.visible = true
		if second_one.animation != "dash":
			second_one.play("dash")
		return

	# Handle wallslide animation
	if is_on_wall_only() and !doWallJump:
		sprite.visible = false
		second_one.visible = true
		if second_one.animation != "wallslide":
			second_one.play("wallslide")
		return

	# Handle airborne animation
	if !is_on_floor():
		sprite.visible = false
		second_one.visible = true
		if second_one.animation != "jump_air":
			second_one.play("jump_air")
		return

	# Handle running animation
	if direction.x != 0:
		sprite.visible = false
		second_one.visible = true
		if second_one.animation != "run":
			second_one.play("run")
		return

	# Fallback to idle animation
	sprite.visible = true
	second_one.visible = false
	if sprite.animation != "idle":
		sprite.play("idle")



func update_facing_direction():
	if direction.x > 0:
		marker_2d.scale.x = 1
		ghost_effect.scale.x = 1
		if second_one.animation == "wallslide":
			marker_2d.scale.x = -1
	elif direction.x < 0:
		marker_2d.scale.x = -1
		ghost_effect.scale.x = -1
		if second_one.animation == "wallslide":
			marker_2d.scale.x = 1

func die():
	GameManager.respawn_player()

func stop_wall_slide():
	if is_on_wall_only():
		has_wall_jumped = false
		wall_grab = false
		update_animation()  # Reset the animation
