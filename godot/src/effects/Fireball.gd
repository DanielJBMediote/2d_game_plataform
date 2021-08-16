extends RigidBody2D

var direction : Vector2
var speed : float = 100
var velocity : Vector2

func init(new_direction: Vector2, new_speed: int):
	direction = new_direction
	speed = new_speed

func _physics_process(delta):
	velocity = direction * (speed * delta)
	
	translate(velocity)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
