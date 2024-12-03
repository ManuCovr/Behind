extends Area2D

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var level_won: Area2D = $"."
@onready var player: CharacterBody2D = $"../Player"
@onready var transition: AnimationPlayer = $"../AnimationPlayer"
var im_here = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	transition.animation_finished.connect(_on_animation_player_animation_finished)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		im_here = true
		transition.play("fade_out")

func _on_body_exited(body: Node2D) -> void:
	if body == player:
		im_here = false
		transition.play_backwards("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if im_here and anim_name == "fade_out":
		get_tree().change_scene_to_file("res://scenes/menu.tscn")
