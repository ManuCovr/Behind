extends Control
@onready var transition: AnimationPlayer = $Transition

func _on_start_button_pressed() -> void:
	transition.play("fade_out")


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_transition_animation_finished(anim_name: StringName) -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")
