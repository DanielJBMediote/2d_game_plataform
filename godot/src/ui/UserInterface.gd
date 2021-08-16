extends CanvasLayer

onready var _Interaction : Control = $InteractionsPanel
onready var _StatsInterface : Control = $StatsInterface

func _ready():
	_Interaction.visible = false
	_StatsInterface.visible = false





