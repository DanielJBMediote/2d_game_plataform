extends Node2D

func _ready():
	UserInterface.init()
	UserInterface.visibility(true)


func _on_Map2_tree_entered():
	get_tree().current_scene = self
	PlayerControl.instance_player(Vector2())
