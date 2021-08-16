extends Button

export (String) var btnLabel = ""

func _ready():
	text = btnLabel


func _on_MainMenuButton_focus_entered():
	set("custom_styles/focus", Color(0, 0, 0, 0))
