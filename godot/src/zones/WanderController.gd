extends Node2D

export(int) var wander_range : int

onready var timer : Timer = $Timer

var target_position = global_position
var start_position = global_position
var isTimerOut : bool

func update_wander_position():
	var x = wander_range
	var y = 0
	var target_vector = Vector2(x, y)
	target_position = start_position + target_vector

func start_wander_time(value: float) ->void:
	timer.start(value)
	isTimerOut = false

func _on_Timer_timeout():
	update_wander_position()
	isTimerOut = true
	wander_range *= -1
