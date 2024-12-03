extends Camera2D

@export var decay : float = 0.8
@export var max_offset : Vector2 = Vector2(100, 75)
@export var max_roll : float = 0.1
@export var follow_node : Node2D
@export var base_offset: Vector2 = Vector2(0, -21)

var trauma : float  = 0.0
var trauma_power : int  = 2

#func _input(event: InputEvent) -> void:
	#if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		#add_trauma(0.4)

func _ready() -> void:
	randomize()
	offset = base_offset

func _process(delta: float) -> void:
	if follow_node:
		global_position = follow_node.global_position
	
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
