extends Control

onready var btnNewGame : Button = get_node("GridContainer").get_children()[0]
onready var btnContinue : Button = get_node("GridContainer").get_children()[1]
onready var btnSettings : Button = get_node("GridContainer").get_children()[2]
onready var btnExit : Button = get_node("GridContainer").get_children()[3]

func _ready():
	btnNewGame.connect("pressed", self, "new_game")
	btnExit.connect("pressed", self, "exit")
	btnContinue.connect("pressed", self, "continue_game")
	btnSettings.connect("pressed", self, "settings")
	
	btnNewGame.grab_focus()
	
func new_game(): _load_game_new_game()

func exit(): get_tree().quit()

func continue_game() ->void: _load_continue_game()

func _load_game_new_game() ->void: get_tree().change_scene("res://godot/src/maps/Tutorial.tscn")
	
func _load_continue_game():
	var player_location : String = PlayerControl.getPlayerInfo()["player"]["map"]
	get_tree().change_scene("res://godot/src/maps/"+player_location+".tscn")

	

