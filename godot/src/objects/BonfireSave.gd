extends Area2D



func _on_BonfireSave_body_entered(body: KinematicBody2D):
	if body.get("_name") == "PLAYER":
		UserInterface._Interaction.visible = true


func _on_BonfireSave_body_exited(body: KinematicBody2D):
	UserInterface._Interaction.visible = false
