extends Area2D

var player : KinematicBody2D = null

func can_see_player() ->bool:
	if player and !player.isDead:
		return true
	else:
		return false

func _on_DetectionZone_body_entered(body):
	if body:
		player = body

func _on_DetectionZone_body_exited(body):
	if body:
		player = null

