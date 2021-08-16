extends Control

onready var health_bar: TextureProgress = $Healthbar
onready var health_bar_under: TextureProgress = $HealthbarUnder
onready var hp_counter : Label = $HPCounter

onready var energy_bar: TextureProgress = $Energybar
onready var energy_bar_under: TextureProgress = $EnergybarUnder
onready var st_counter : Label = $STCounter

onready var mana_bar: TextureProgress = $Manabar
onready var arrows_counter: Label = $ArrowsAmount
onready var level_progress: TextureProgress = $LevelProgress
onready var level_progress_under: TextureProgress = $LevelProgressUnder
onready var level: Label = $PlayerLevel
onready var energy_timer: Timer = $EnergyTimer
onready var health_timer: Timer = $HealthTimer
onready var _Tween: Tween = $Tween

onready var animationPlayer : AnimationPlayer = $AnimationPlayer

var green_color : Color = Color(0.262745, 1, 0.227451)
var orange_color : Color = Color(1, 0.533333, 0.227451)
var red_color : Color = Color(1, 0.276367, 0.276367)

func _ready():
	level.text = str(PlayerStats.get("level"))
	health_bar.max_value = PlayerStats.get("max_health")
	health_bar_under.max_value = PlayerStats.get("max_health")
	energy_bar.max_value = PlayerStats.get("max_energy")
	energy_bar_under.max_value = PlayerStats.get("max_energy")
	mana_bar.max_value = PlayerStats.get("max_mana")

	level_progress.max_value = PlayerStats.get("exp_to_next")
	level_progress_under.max_value = PlayerStats.get("exp_to_next")
	arrows_counter.text = "x"+str(PlayerStats.get("arrows"))

	level_progress.value = PlayerStats.get("experience")
	level_progress_under.value = PlayerStats.get("experience")
	health_bar.value = PlayerStats.get("health")
	health_bar_under.value = PlayerStats.get("health")
	energy_bar.value = PlayerStats.get("energy")
	energy_bar_under.value = PlayerStats.get("energy")
	mana_bar.value = PlayerStats.get("mana")

	update_health_colors()


func _process(delta):
	if PlayerStats.energy > PlayerStats.max_energy:
		PlayerStats.energy = PlayerStats.max_energy
	if PlayerStats.health > PlayerStats.max_health:
		PlayerStats.health = PlayerStats.max_health
		
	st_counter.text = str(PlayerStats.energy)+"/"+str(PlayerStats.max_energy)
	hp_counter.text = str(PlayerStats.health)+"/"+str(PlayerStats.max_health)
	
func update_experience(value: float):
	if PlayerStats.experience < PlayerStats.exp_to_next:
		PlayerStats.experience += value
		level_progress.value = PlayerStats.experience
		_Tween.interpolate_property(
			level_progress_under,
			"value",
			level_progress_under.value,
			PlayerStats.experience + value,
			0.5,
			Tween.TRANS_LINEAR
		)
		_Tween.start()
		if PlayerStats.experience >= PlayerStats.exp_to_next:
			PlayerStats.updateLevelCap()
			PlayerStats.experience -= level_progress.max_value
			level_progress.max_value = PlayerStats.get("exp_to_next")
			level_progress_under.max_value = PlayerStats.get("exp_to_next")
			level_progress.value = PlayerStats.experience
			level_progress_under.value = PlayerStats.experience
			level.text = str(PlayerStats.level)
			
			play_animation("lvl_up_anim")

func update_arrows(value: int):
	if PlayerStats.get("arrows") > 0:
		PlayerStats.set("arrows", PlayerStats.get("arrows") + value)
		arrows_counter.text = "x"+str(PlayerStats.get("arrows"))


func update_energy(value: int = 1) -> void:
	if PlayerStats.get("energy") > 0:
		PlayerStats.energy += value
		energy_bar.value = PlayerStats.energy
		_Tween.interpolate_property(
			energy_bar_under,
			"value",
			energy_bar_under.value,
			PlayerStats.energy + value,
			0.3,
			Tween.TRANS_SINE
		)
		_Tween.start()
	
	

func update_health(value: int = 1):
	if PlayerStats.get("health") > 0:
		PlayerStats.health += value
		health_bar.value = PlayerStats.health
		_Tween.interpolate_property(
			health_bar_under,
			"value",
			health_bar_under.value,
			PlayerStats.health + value,
			0.3,
			Tween.TRANS_SINE
		)
		_Tween.start()
	update_health_colors()
	

func update_health_colors():
	if health_bar.value < (health_bar.max_value * 0.5):
		health_bar.set("tint_progress", red_color)
	elif health_bar.value >= (health_bar.max_value * 0.5) and health_bar.value <= (health_bar.max_value * 0.75):
		health_bar.set("tint_progress", orange_color)
	else:
		health_bar.set("tint_progress", green_color)

func _on_EnergyTimer_timeout():
	if PlayerStats.get("energy") < PlayerStats.get("max_energy"):
		update_energy(PlayerStats.get("energy_regen"))
		energy_timer.start(1)

func _on_HealthTimer_timeout():
	if PlayerStats.get("health") < PlayerStats.get("max_health"):
		update_health(PlayerStats.get("health_regen"))
		health_timer.start(1)


func play_animation(anima: String):
	animationPlayer.play(anima)
