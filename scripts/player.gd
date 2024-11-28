extends CharacterBody2D

@export var SPEED : float = 100.0
@export var JUMP_VELOCITY : float = -160.0
@export var double_jump_velocity : float = -130
@onready var marker_2d: Marker2D = $Marker2D
@onready var sprite: AnimatedSprite2D = $Marker2D/AnimatedSprite2D

var has_double_jumped : bool = false
var animation_locked: bool = false
var direction : Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		has_double_jumped = false

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif not has_double_jumped:
			velocity.y = double_jump_velocity
			has_double_jumped = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	direction = Input.get_vector("left", "right", "up", "down")
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	move_and_slide()
	update_animation()
	update_facing_direction()

func update_animation():
	if not animation_locked:
		if direction.x != 0:
			sprite.play("run")
		else:
			sprite.play("idle")
	
func update_facing_direction():
	if direction.x > 0:
		marker_2d.scale.x=1
	if direction.x < 0:
		marker_2d.scale.x=-1
		
			
			
			
