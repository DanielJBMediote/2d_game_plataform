extends KinematicBody2D

onready var animatedSprite: AnimatedSprite = $AnimatedSprite
onready var wanderController: Node2D = $WanderController
onready var mobStats : Control = $MobStats

onready var zoneDetection: Area2D = $DetectionZone
onready var floorDetection: Area2D = $FloorDetection

onready var enemyHitbox : Area2D = $Enemyhitbox
onready var enemyHurtbox : Area2D = $Hurtbox


const GRAVITY: int = 20
const ACCELERATION: int = 600
const FRICCTION: int = 800
const MAX_SPEED: int = 100
const JUMP_HEIGHT: int = -80
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGHT: float = 32.0
const SLOPE_THRESHOLD: float = deg2rad(45)
const SLIDE_SPEED: int = 750

enum { IDLE, WANDER, CHASE }
var state = IDLE

var motion : Vector2 = Vector2.ZERO
var moveDirection: Vector2 = Vector2.ZERO
var idleDirection: Vector2 = Vector2.ZERO
var snapVector: Vector2  # Same of over
var knokback : Vector2
var distanceToPlayer : float

var isAttackFinished: bool = true
var isDeading : bool = false

func _ready():
	wanderController.start_position = position
	wanderController.start_wander_time(rand_range(1, 2))
	enemyHitbox.get_node("CollisionShape2D").disabled = true
	
func _process(delta):

	if not isDeading:
		motion.y += GRAVITY
		_flip_AnimatedSprite()

		match state:
			IDLE:
				_idle_state(delta)
			WANDER:
				_wander_state(delta)
			CHASE:
				_chase_state(delta)

		if floorDetection.isOnFloor:
			motion.y = _move()
			knokback = knokback.move_toward(Vector2.ZERO, 120 * delta)
			knokback = move_and_slide(knokback)
		else:
			state = _pick_random_state([IDLE, WANDER])

func _seek_player():
	if zoneDetection.can_see_player():
		state = CHASE

func _flip_AnimatedSprite():
	if moveDirection < Vector2.ZERO and moveDirection >= Vector2.LEFT:
		idleDirection = Vector2.LEFT
		animatedSprite.flip_h = true
		zoneDetection.get_node("CollisionShape2D").position.x = -140
		floorDetection.get_node("CollisionShape2D").position.x = -10
		if ["idle", "move", "hurt", "dead"].has(animatedSprite.animation):
			animatedSprite.position = Vector2(-5, -30)
		elif animatedSprite.animation == "attack":
			enemyHitbox.get_node("CollisionShape2D").position = Vector2(-30, -25)
			animatedSprite.position = Vector2(-12, -33)
	elif moveDirection > Vector2.ZERO and moveDirection <= Vector2.RIGHT:
		idleDirection = Vector2.RIGHT
		zoneDetection.get_node("CollisionShape2D").position.x = 140
		floorDetection.get_node("CollisionShape2D").position.x = 10
		animatedSprite.flip_h = false
		if ["idle", "move", "hurt", "dead"].has(animatedSprite.animation):
			animatedSprite.position = Vector2(5, -30)
		elif animatedSprite.animation == "attack":
			enemyHitbox.get_node("CollisionShape2D").position = Vector2(30, -25)
			animatedSprite.position = Vector2(12, -33)
	enemyHitbox.hit_direction = idleDirection

func _move():
	return move_and_slide_with_snap(motion, snapVector, Vector2.UP, false, 4, SLOPE_THRESHOLD).y

func _pick_random_state(states_list: Array):
	return states_list[randi() % states_list.size()]


func _idle_state(delta):
	_seek_player()
	if wanderController.isTimerOut:
		state = _pick_random_state([WANDER, IDLE])
		wanderController.start_wander_time(rand_range(2, 3))

	animatedSprite.play("idle")
	motion = motion.move_toward(Vector2(), FRICCTION * delta)


func _wander_state(delta):
	_seek_player()
	if wanderController.isTimerOut:
		state = _pick_random_state([IDLE, WANDER])
		wanderController.start_wander_time(rand_range(1, 2))

	animatedSprite.play("move")
	moveDirection = position.direction_to(wanderController.target_position)
	motion = motion.move_toward(moveDirection * MAX_SPEED, ACCELERATION * delta)

	if position.distance_to(wanderController.target_position) <= 4 and floorDetection.isOnFloor:
		state = _pick_random_state([IDLE, WANDER])
		wanderController.start_wander_time(rand_range(1, 2))


func _chase_state(delta):
	if ["hurt", "attack"].has(animatedSprite.animation):
		motion = motion.move_toward(Vector2.ZERO, FRICCTION * delta)
		yield(animatedSprite, "animation_finished")
	if zoneDetection.can_see_player() and floorDetection.isOnFloor == true:
		distanceToPlayer = position.distance_to(zoneDetection.player.global_position)

		if isAttackFinished and distanceToPlayer < 30:
			animatedSprite.play("attack")
			motion = motion.move_toward(Vector2.ZERO, FRICCTION * delta)
		else:
			var direction: Vector2 = (zoneDetection.player.position).direction_to(position)
			moveDirection = - direction.normalized()
			
			enemyHitbox.get_node("CollisionShape2D").disabled = true
			animatedSprite.play("move")
			motion = motion.move_toward(moveDirection * (MAX_SPEED), ACCELERATION * delta)
	else:
		state = _pick_random_state([IDLE, WANDER])
		wanderController.start_wander_time(1)

func _on_AnimatedSprite_animation_finished():
	if ["attack"].has(animatedSprite.animation):
		isAttackFinished = true
		enemyHitbox.get_node("CollisionShape2D").disabled = true
		if zoneDetection.can_see_player():
			state = CHASE
	if ["hurt"].has(animatedSprite.animation):
		if not zoneDetection.can_see_player():
			state = _pick_random_state([IDLE, WANDER])
		else:
			state = CHASE

func _on_AnimatedSprite_frame_changed():
	if animatedSprite.animation == "attack":
		if animatedSprite.frame == 6:
			enemyHitbox.get_node("CollisionShape2D").disabled = false


func _on_Hurtbox_area_entered(area: Area2D):
	if area.name == "Playerhitbox":
		animatedSprite.play("hurt")
		knokback = area.get("hit_direction") * 50
	elif area.name == "Arrowhitbox":
		animatedSprite.play("hurt")
		knokback = area.get("hit_direction") * 50
		area.get_parent().queue_free()
	mobStats.update_health(-area.get("damage"))
	dead()

func dead():
	if mobStats.health <= 0:
		calculate_exp()
		isDeading = true
		animatedSprite.play("dead")
		yield(animatedSprite, "animation_finished")
		queue_free()

func calculate_exp():
	mobStats.play_exp_animaiton()
	UserInterface._StatsInterface.update_experience(mobStats.experience)
