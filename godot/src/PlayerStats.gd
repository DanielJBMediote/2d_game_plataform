extends Node

var player_stats = PlayerControl.getPlayerInfo()["player_stats"]

var max_health : float = player_stats["max_health"]
var max_energy : float = player_stats["max_energy"]
var max_mana : float = player_stats["max_mana"]
var energy : float = player_stats["energy"]
var health : float = player_stats["health"]
var mana : float = player_stats["mana"]

var health_regen : float = player_stats["health_regen"]
var mana_regen : float = 1
var energy_regen : float = player_stats["energy_regen"]

var attack_speed : float = player_stats["attack_speed"]
var shot_speed : float = player_stats["shot_speed"]
var arrows : int = player_stats["arrows_amount"]
var arrow_damage : float = player_stats["arrow_damage"]
var level : int = player_stats["level"]

var experience : float = 0
var exp_to_next : float = player_stats["experience_to_next"]

func updateLevelCap():
	if experience >= exp_to_next:
		level += 1
		exp_to_next = level * 10
