extends CharacterBody2D

@onready var area_2d: Area2D = $Area2D
@onready var dialogue: MarginContainer = $Dialogue

const lines: Array[String] = [
	"...",
	"Oh hey there, 
	I didn't see you.",
	"I'm assuming you're not 
	from around here...",
	"I'm Mob, by the way.",
	"...",
	"Oh, where are you? 
	It's a long story, 
	I hope you have time.",
	"The world kinda went kaboom.",
	"Huh. Shorter than I remembered.",
	"Anyways, if you want any chance 
	at survival, you gotta get to that platform 
	up there.",
	"Try using A and D to move 
	left and right. OH AND SPACE TO JUMP",
]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if area_2d.get_overlapping_bodies().size() > 0:
			DialogManager.start_dialog(dialogue.position, lines)
			
