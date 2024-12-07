extends Camera2D

@onready var size: Vector2 = get_viewport_rect().size  # Viewport size as a Vector2
@export var decay: float = 0.5
@export var max_offset: Vector2 = Vector2(80, 60)
@export var max_roll: float = 0.1
@export var follow_node: Node2D
@export var base_offset: Vector2 = Vector2(0, -10)  # Keeps the shake functionality intact
@export var camera_smoothness: float = 0.1

@export var cell_size: Vector2 = Vector2(380, 200)  # Size of each cell in pixels
@export var grid_size: Vector2i = Vector2i(5, 3)  # Number of cells (columns, rows)
@export var smooth_transition: bool = false  # Toggle smooth camera transitions
@export var transition_speed: float = 5.0  # Speed for smooth transitions

var cur_screen: Vector2 = Vector2.ZERO  # Current cell position
var trauma: float = 0.0
var trauma_power: int = 2
var initialized: bool = false
var custom_offset_y: float = -100  # Adjust this value to raise the camera

func _ready() -> void:
	if follow_node:
		cur_screen = get_current_cell()
		global_position = cur_screen * cell_size + base_offset
		initialized = true
	randomize()

func _physics_process(delta: float) -> void:
	if follow_node:
		var target_cell = get_current_cell()
		target_cell = clamp_cell(target_cell)  # Clamp to grid boundaries

		if target_cell != cur_screen:
			cur_screen = target_cell

		if smooth_transition:
			var target_position = cur_screen * cell_size + base_offset
			global_position = lerp(global_position, target_position, delta * transition_speed)
		else:
			global_position = cur_screen * cell_size + base_offset

	# Apply custom Y offset to raise the camera
	global_position.y += custom_offset_y

	# Apply trauma-based shaking
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		shake()

func get_current_cell() -> Vector2:
	# Determine the cell based on the follow node's position
	return Vector2i(follow_node.global_position / cell_size)

func clamp_cell(cell: Vector2) -> Vector2:
	# Ensure the cell stays within the grid bounds
	return Vector2(
		clamp(cell.x, 0, grid_size.x - 1),
		clamp(cell.y, 0, grid_size.y - 1)
	)

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	var amount = pow(trauma, trauma_power)
	offset.x = base_offset.x + max_offset.x * amount * randf_range(-1, 1)
	offset.y = base_offset.y + max_offset.y * amount * randf_range(-1, 1)
	rotation = max_roll * amount * randf_range(-1, 1)
