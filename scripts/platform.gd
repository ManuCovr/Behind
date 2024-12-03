extends AnimatableBody2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var player: CharacterBody2D = $"../../Player"
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var area_2d: Area2D = $Area2D

var player_on_top: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area_2d.body_entered.connect(_on_area_2d_body_entered)
	area_2d.body_exited.connect(_on_area_2d_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player and is_player_directly_on_top():
		player_on_top = true
		_check_and_play_animation()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player:
		player_on_top = false
		_check_and_reverse_animation()

func is_player_directly_on_top() -> bool:
	# Check if the player is directly above the platform
	return player.is_on_floor() and !player.is_on_wall()

func _check_and_play_animation():
	# Ensure the player is on the platform and on the ground
	if player_on_top:
		animation_player.play("elevator")

func _check_and_reverse_animation():
	# Reverse the animation if the player is no longer on top
	if !player_on_top:
		animation_player.play_backwards("elevator")
