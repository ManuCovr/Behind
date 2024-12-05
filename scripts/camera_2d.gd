extends Camera2D

@export var decay : float = 0.5
@export var max_offset : Vector2 = Vector2(80, 60)
@export var max_roll : float = 0.1
@export var follow_node : Node2D
@export var base_offset: Vector2 = Vector2(0, -10)
@export var camera_smoothness : float = 0.1

var trauma : float  = 0.0
var trauma_power : int  = 2
var initialized : bool = false
# Smoothness factor

func _ready() -> void:
	# Ensure the camera starts at the correct position
	if follow_node:
		global_position = follow_node.global_position + base_offset
		initialized = true
	randomize()
	offset = base_offset

func _process(delta: float) -> void:
	if follow_node:
		# Smoothly interpolate camera position towards the follow node using lerp()
		var target_position = follow_node.global_position + base_offset
		global_position.x = lerp(global_position.x, target_position.x, camera_smoothness)
		global_position.y = lerp(global_position.y, target_position.y, camera_smoothness)

	if trauma:
		trauma = max(trauma - decay * delta, 0)
		shake()

func add_trauma(amount : float) -> void:
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	var amount = pow(trauma, trauma_power)
	offset = Vector2.ZERO
	offset.x = base_offset.x + max_offset.x * amount * randf_range(-1, 1)
	offset.y = base_offset.y + max_offset.y * amount * randf_range(-1, 1)
	rotation = max_roll * amount * randf_range(-1, 1)
