extends Area2D

var isOnFloor : bool
var isStaticBody : bool

func _on_FloorDetection_body_entered(body : StaticBody2D):
	if body.collision_layer == 1:
		isOnFloor = true

func _on_FloorDetection_body_exited(body : StaticBody2D):
	if body.collision_layer == 1:
		isOnFloor = false
