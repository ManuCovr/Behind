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


const lines2: Array[String] = [
	"You made it!",
	"Really thought you
	were gonna... You know...",
	"Anyways!",
	"...",
	"You never told me your name.",
	"...",
	"Kodai...",
	"*could it be...?*",
	"Same thing as last time,
	just jump."
]

var current_scene_name = ""  # Set this explicitly for each scene

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and area_2d.get_overlapping_bodies().size() > 0:
		var selected_lines: Array[String]
		
		# Use the current scene name from the global singleton
		var current_scene_name = SceneManager.current_scene_name
		
		match current_scene_name:
			"game":
				selected_lines = lines
			"level1":
				selected_lines = lines2
			_:
				selected_lines = ["I don't know where we are!"]

		# Start the dialogue with the selected lines
		DialogManager.start_dialog(dialogue.position, selected_lines)
