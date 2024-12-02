extends CharacterBody2D

@export var jump_buffer_buffer : float = 0.1 
@export var RunSpeed : float = 130.0
@export var JUMP_VELOCITY : float = -220.0
@export var wall_slide_speed : float = 1400
@export var run_accel = 1000
@export var gravity_multiplyer : float = 1.5
@export var dash_delay : float = 0.7

@onready var dash_timer: Timer = $Dash/DashTimer
@onready var dash_particles: GPUParticles2D = $dash_particles
@export var dash_sprite : PackedScene
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var marker_2d: Marker2D = $Marker2D
@onready var sprite: AnimatedSprite2D = $Marker2D/AnimatedSprite2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer
@onready var dash: Node2D = $Dash
@onready var hitbox: CollisionShape2D = $hitbox/CollisionShape2D

var can_jump : bool = true
var has_wall_jumped : bool = false
var doWallJump : bool = false
var jump_buffer : bool = false
var animation_locked: bool = false
var direction : Vector2 = Vector2.ZERO
var was_on_air : bool = false
var can_dust : bool = true
var dash_direction = Vector2.ZERO

const acc = 600
const dashspeed = 420
const dashlenght = 0.15



func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
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
	if is_on_wall_only() and !Input.is_action_just_pressed("jump") and !doWallJump:
		wall_slide(delta)
	direction.x = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
	#direction.y = sign(Input.get_action_strength("down") - Input.get_action_strength("up"))
	if Input.is_action_just_pressed("dash") and !dash.is_dashing() and direction.x != 0 and dash.can_dash:
		dash_particles.emitting = true
		dash.start_dash(dashlenght)
		velocity.x = (direction.x if direction.x != 0 else marker_2d.scale.x) * dashspeed
		dash.can_dash = false
	if dash.is_dashing():
		#FrameFreeze(0.05, 1.0)
		hitbox.disabled = false
		velocity.x = sign(velocity.x) * dashspeed
	else:
		direction.x = sign(Input.get_action_strength("right") - Input.get_action_strength("left"))
		dash_particles.emitting = false
		hitbox.disabled = true
		if direction and !doWallJump:
			velocity.x = clamp(velocity.x + direction.x * acc * delta, -RunSpeed, RunSpeed)
		elif not doWallJump:
			velocity.x = move_toward(velocity.x, 0, run_accel * delta)

	# Move and Slide
	var was_on_floor = is_on_floor()
	
	move_and_slide()
	update_animation()
	update_facing_direction()

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

func _on_enemy_killed():
	# Reset dash and allow a small window to dash again
	dash.can_dash = true  # Allow re-dash
	dash_particles.emitting = false  # Stop dash particles

# Wall Jump Implementation
func wall_jump():
	# Get the wall normal to determine the jump direction
	var wall_direction = get_wall_normal()
	velocity.x = wall_direction.x * RunSpeed * 1.5  # Push away from the wall
	velocity.y = JUMP_VELOCITY  # Boost upward
	has_wall_jumped = true  # Prevent multiple wall jumps
	can_jump = false
	doWallJump = true
	$WallJumpTimer.start()
	sprite.play("jump_start")  # Play wall jump animation

# Wall Slide Implementation
func wall_slide(delta: float):
	velocity.y = min(velocity.y, wall_slide_speed * delta)  # Apply slide speed cap
	sprite.play("wallslide")  # Play wall slide animation if it exists

# Reset Wall Jump State
func reset_wall_jump():
	doWallJump = false
	has_wall_jumped = false

func jump():
	if can_jump and (is_on_floor() || !coyote_timer.is_stopped()):
		velocity.y = JUMP_VELOCITY
		sprite.play("jump_start")
		can_jump = false
		reset_jump_buffer()
	elif was_on_air and jump_buffer:
		velocity.y = JUMP_VELOCITY
		sprite.play("jump_start")
		can_jump = false
		reset_jump_buffer()

func reset_jump_buffer():
	jump_buffer = false
	jump_buffer_timer.stop()
	
func _on_wall_jump_timer_timeout() -> void:
	reset_wall_jump()

func _on_jump_buffer_timer_timeout():
	reset_jump_buffer()

func update_animation():
	if not animation_locked:
		#if dash.is_dashing():
			#sprite.play("dash")
		if !is_on_floor() and !is_on_wall_only():
			sprite.play("jump_air")
		elif is_on_wall_only() and !doWallJump:
			sprite.play("wallslide")  # Slide animation if on wall but not jumping
		elif direction.x != 0:
			sprite.play("run")
		else:
			sprite.play("idle")

func update_facing_direction():
	if direction.x > 0:
		marker_2d.scale.x = 1
	elif direction.x < 0:
		marker_2d.scale.x = -1
		
func FrameFreeze(timeScale, duration):
	Engine.time_scale = timeScale
	var timer = get_tree().create_timer(timeScale * duration)
	await timer.timeout
	Engine.time_scale = 1 

func reset_dash():
	dash.can_dash = true
	var redash = get_tree().create_timer(dash_delay)
	await redash.timeout
	dash.can_dash = false
	dash_particles.emitting = false
