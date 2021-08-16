extends Node

func instance_player():
	var new_player: KinematicBody2D = load('res://godot/src/players/Player.tscn').instance()
	var info = {
		"position" : Vector2(
			getPlayerInfo()["player_info"]["position"]["x"],
			getPlayerInfo()["player_info"]["position"]["y"]),
	}
#	if get_tree().network_peer:
#		new_player.name = str(get_tree().get_network_unique_id())
#		new_player.set_network_master(get_tree().get_network_unique_id())
#		info = Network.self_data
#	else:
#		info = {position = initical_position}
	
	new_player._instance(info["position"], false)
	get_tree().current_scene.get_node("World/Entities").add_child(new_player)

func getPlayerInfo():
	return FileManager.read()
