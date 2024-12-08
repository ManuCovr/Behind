extends Node2D

@onready var timer: Timer = $DashTimer
const dash_delay = 1
var can_dash = true
var player_ref : Node = null

func set_player_reference(player: Node):
	player_ref = player

func start_dash(dur: float):
	if can_dash:
		can_dash = false
		timer.wait_time = dur
		timer.start()

func is_dashing() -> bool:
	return timer.time_left > 0

func end_dash():
	if not can_dash:  # Only reset if it has been used
		var new_timer = get_tree().create_timer(dash_delay)
		await new_timer.timeout
		can_dash = true


func _on_dash_timer_timeout() -> void:
	end_dash()
