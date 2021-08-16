extends Node2D

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	UserInterface._StatsInterface.visible = true

	$TipsInterface/Tips1/buttons_animations.play("moving_button")
	$TipsInterface/Tips2/buttons_animations.play("moving_button")
	$TipsInterface/Tips3/buttons_animations.play("moving_button")

func _on_player_disconnected(id: int) ->void:
	get_node("Objects/"+str(id)).queue_free()

func _on_server_disconnected() ->void:
	get_tree().change_scene("res://godot/src/interfaces/Main.tscn")

func _on_Map01_tree_entered():
	get_tree().current_scene = self
	PlayerControl.instance_player()

func _on_EndHole_body_entered(body: KinematicBody2D):
	if body.get("_name") == "PLAYER":
		body.position = Vector2()
