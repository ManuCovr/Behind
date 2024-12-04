extends Node

@onready var text_box_scene = preload("res://dialogues/dialogue.tscn")

var dialogue_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var is_dialog_active = false
var can_advance_line = false

func start_dialog(position: Vector2, lines: Array[String]):
	if is_dialog_active:
		return
	
	dialogue_lines = lines
	text_box_position = position
	_show_text_box()
	is_dialog_active = true
	
func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished.connect(_on_text_box_finished_displaying)
	get_tree().root.add_child(text_box)

	# Adjust position correctly
	if text_box is Control:
		text_box.global_position = text_box_position
	elif text_box is Node2D:
		text_box.global_position = text_box_position

	text_box.display(dialogue_lines[current_line_index])
	can_advance_line = false

func _on_text_box_finished_displaying():
	can_advance_line = true
	
	# Ensure the dialogue ends cleanly
	if current_line_index >= dialogue_lines.size():
		text_box.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_dialog_active and can_advance_line:
		text_box.queue_free()
		current_line_index += 1
		
		if current_line_index >= dialogue_lines.size():
			is_dialog_active = false
			current_line_index = 0
			return
		
		_show_text_box()
