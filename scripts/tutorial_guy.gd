extends CharacterBody2D

@onready var area_2d: Area2D = $Area2D
@onready var dialogue: MarginContainer = $Dialogue
@onready var press: Label = $Press

const lines: Array[String] = [
	"...",
	"Oh hey!
	Who are you...?",
	"...",
	"Ah Kodai, cool name.
	I'm Mob by the way.",
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
	"Cool name. You remember
	what you did last time right?",
	"Same thing,
	just jump."
]

const lines3: Array[String] = [
	"Hey again...",
	"Alright so now.",
	"I'm gonna teach you
	something.",
	"There's a wall over there",
	"You can't clear it with a
	regular jump.",
	"...",
	"You see there's something
	called a WALL JUMP",
	"I know it's gonna sound odd but,
	all you gotta do is jump against the
	wall.",
	"And then jump again..."
]

var current_scene_name = ""  # Set this explicitly for each scene

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and area_2d.get_overlapping_bodies().size() > 0:
		press.visible = false
		var selected_lines: Array[String]
		
		# Use the current scene name from the global singleton
		var current_scene_name = SceneManager.current_scene_name
		
		match current_scene_name:
			"game":
				selected_lines = lines
			"level1":
				selected_lines = lines2
			"level2":
				selected_lines = lines3
			_:
				selected_lines = ["I don't know where we are!"]

		# Start the dialogue with the selected lines
		DialogManager.start_dialog(dialogue.position, selected_lines)
