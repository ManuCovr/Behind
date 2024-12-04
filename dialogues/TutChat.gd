extends MarginContainer

@onready var timer: Timer = $Timer
@onready var label: Label = $MarginContainer/chat
@onready var margin_container: MarginContainer = $MarginContainer

@export_file("*.json") var d_file
var MAX_WIDTH = 256
var text = ""
var letter_index = 0

var letter_time = 0.03
var space_time = 0.06
var punctuation_time = 0.2

signal finished()

func display(text_to_display: String):
	text = text_to_display
	label.text = text_to_display
	
	size = label.get_minimum_size()  # Get the label's size
	margin_container.global_position.x -= size.x / 2
	margin_container.global_position.y -= size.y + 24
	
	label.text = ""
	_display_letter()
	
func _display_letter():
	label.text += text[letter_index]
	letter_index += 1
	if letter_index >= text.length():
		finished.emit()
		return
	match text[letter_index]:
		"!", ".", ",", "?":
			timer.start(punctuation_time)
		" ":
			timer.start(space_time)
		_:
			timer.start(letter_time)

func _on_timer_timeout() -> void:
	_display_letter()
