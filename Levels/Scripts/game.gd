extends Node2D


func _ready():
	SceneManager.current_scene_name = "game"


func _on_player_change_camera_pos(player_pos) -> void:
	$Player/Camera2D.position.x = player_pos
