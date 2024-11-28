extends CharacterBody2D

@export var jump_buffer_buffer : float = 0.1 
@export var SPEED : float = 100.0
@export var JUMP_VELOCITY : float = -180.0
@export var wall_slide_speed : float = 1400

@onready var marker_2d: Marker2D = $Marker2D
@onready var sprite: AnimatedSprite2D = $Marker2D/AnimatedSprite2D
@onready var jump_buffer_timer: Timer = $JumpBufferTimer

var can_jump : bool = true
var has_wall_jumped : bool = false
var doWallJump : bool = false
var jump_buffer : bool = false
var animation_locked: bool = false
var direction : Vector2 = Vector2.ZERO
var was_on_air : bool = false

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		was_on_air = true

	# Handle Jumping
	if Input.is_action_just_pressed("jump"):
		if is_on_wall_only() and !has_wall_jumped:
			wall_jump()
		elif is_on_floor() and can_jump:
			jump()
		elif !is_on_floor() and was_on_air and !jump_buffer:
			# Activate jump buffer if in the air
			jump_buffer = true
			jump_buffer_timer.start()


	# Wall Slide
	if is_on_wall_only() and !Input.is_action_just_pressed("jump") and !doWallJump:
		wall_slide(delta)

	# Movement
	direction = Input.get_vector("left", "right", "up", "down")
	if direction and !doWallJump:
		velocity.x = direction.x * SPEED
	elif not doWallJump:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Move and Slide
	var was_on_floor = is_on_floor()
	move_and_slide()
	update_animation()
	update_facing_direction()

	# Touched Ground
	if !was_on_floor and is_on_floor():
		reset_wall_jump()
		can_jump = true
		if jump_buffer:
			reset_jump_buffer()
			jump()
	# Left the Wall
	if !is_on_wall_only():
		has_wall_jumped = false

# Wall Jump Implementation
func wall_jump():
	# Get the wall normal to determine the jump direction
	var wall_direction = get_wall_normal()
	velocity.x = wall_direction.x * SPEED * 1.5  # Push away from the wall
	velocity.y = JUMP_VELOCITY  # Boost upward
	has_wall_jumped = true  # Prevent multiple wall jumps
	can_jump = false
	doWallJump = true
	$WallJumpTimer.start()
	sprite.play("jump_start")  # Play wall jump animation


# Wall Slide Implementation
func wall_slide(delta: float):
	velocity.y = min(velocity.y, wall_slide_speed * delta)  # Apply slide speed cap
	#sprite.play("wall_slide")  # Play wall slide animation if it exists

# Reset Wall Jump State
func reset_wall_jump():
	doWallJump = false
	has_wall_jumped = false

func jump():
	if is_on_floor() and can_jump:
		velocity.y = JUMP_VELOCITY
		sprite.play("jump_start")
		reset_jump_buffer()
	elif was_on_air and jump_buffer:
		velocity.y = JUMP_VELOCITY
		sprite.play("jump_start")
		reset_jump_buffer()
	# Buffer Jump
	#if was_on_air and !jump_buffer and can_jump:
		#jump_buffer = true
		#jump_buffer_timer.start()
func reset_jump_buffer():
	jump_buffer = false
	jump_buffer_timer.stop()
	
func _on_wall_jump_timer_timeout() -> void:
	reset_wall_jump()

func _on_jump_buffer_timer_timeout():
	reset_jump_buffer()

func update_animation():
	if not animation_locked:
		if !is_on_floor() and !is_on_wall_only():
			sprite.play("jump_air")
		#elif is_on_wall_only() and !doWallJump:
			#sprite.play("wall_slide")  # Slide animation if on wall but not jumping
		elif direction.x != 0:
			sprite.play("run")
		else:
			sprite.play("idle")

func update_facing_direction():
	if direction.x > 0:
		marker_2d.scale.x = 1
	if direction.x < 0:
		marker_2d.scale.x = -1
