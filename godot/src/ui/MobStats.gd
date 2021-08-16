extends Control

#export(int) var level
export(float) var experience
export(float) var health

var red_color = Color(1, 0.419608, 0.419608)
var gray_color = Color(0.737305, 0.737305, 0.737305)

func _ready():
	$Health.max_value = health
	$HealthUnder.max_value = health
	$Health.value = health
	$HealthUnder.value = health
#	$lavel.text = "Lv." + str(level)
	$XP.visible = false
	$XP.text = "Exp "+str(experience)
#	if level > PlayerStats.get("level"): $lavel.set("custom_colors/font_color", red_color)
#	else:$lavel.set("custom_colors/font_color", gray_color)

func update_health(value: float) ->void:
	health += value
	$Tween.interpolate_property($HealthUnder, "value", $Health.value, health, 0.4, Tween.TRANS_LINEAR)
	$Tween.start()
	$Health.value = health

func play_exp_animaiton():
	$XP.visible = true
	$AnimationPlayer.play("xp_show")
