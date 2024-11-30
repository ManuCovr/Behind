extends Control
@onready var transition: AnimationPlayer = $Transition
@onready var music: AudioStreamPlayer2D = $Music

func _on_start_button_pressed() -> void:
	transition.play("fade_out")
	music.stop()


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_transition_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_music_finished() -> void:
	music.play()
