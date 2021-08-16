extends RigidBody2D

onready var hitbox : Area2D = $Arrowhitbox

const DEFAULT_SPEED : int = 200

var damage : float = 1 setget setDamage

var arrow_direction : Vector2
var velocity : Vector2
var speed : int 

func _ready():
	damage = PlayerStats.get("arrow_damage")
	hitbox.damage = damage

func setDamage(value: float):
	damage = value

func init(new_direction: Vector2, new_speed = DEFAULT_SPEED):
	arrow_direction = new_direction
	speed = new_speed
	$Arrowhitbox.hit_direction = arrow_direction

func _physics_process(delta):
	translate(arrow_direction * (speed * delta))

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
