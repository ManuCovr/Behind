extends Node

func hit_stop_short():
	Engine.time_scale = 0
	await get_tree().create_timer(0.15, true, false, true).timeout
	Engine.time_scale = 1
	
	
func hit_stop_med():
	Engine.time_scale = 0
	await get_tree().create_timer(0.5, true, false, true).timeout
	Engine.time_scale = 1
	
func slow_mow():
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.5, true, false, true).timeout
	Engine.time_scale = 1

func Dash_slow():
	Engine.time_scale = 0.5
	await get_tree().create_timer(0.15, true, false, true).timeout
	Engine.time_scale = 1

func wall_break():
	Engine.time_scale = 1.5
	await get_tree().create_timer(0.15, true, false, true).timeout
	Engine.time_scale = 1
