extends KinematicBody2D

var arrow = preload("res://godot/src/effects/Arrow.tscn")

const _name = "PLAYER"

onready var animatedSprite: AnimatedSprite = get_node("AnimatedSprite")
onready var playerHurtbox: Area2D = $Hurtbox
onready var playerHitbox : Area2D = $Playerhitbox

const GRAVITY: int = 20
const ACCELERATION: int = 500
const FRICCTION: int = 800
const MAX_SPEED: int = 200
const JUMP_HEIGHT: int = -480
const SNAP_DIRECTION: Vector2 = Vector2.DOWN
const SNAP_LENGHT: float = 32.0
const SLOPE_THRESHOLD: float = deg2rad(45)
const JUMP_TIMES_LIMIT: int = 1
const SLIDE_SPEED: int = 750

var motion: Vector2 = Vector2.ZERO  # Variable to make the movement Vector of player
var moveDirection: Vector2 = Vector2.ZERO  # Variable to make de direction movement of player
var snap: bool = false  # I dont't know, i just copied from GitHub xD
var snapVector: Vector2  # Same of over
var idleDirection: Vector2 = Vector2.RIGHT

var slope_angle: float
var motion_angle: float
var distaceToFloor: Vector2

var canDoubleJump: bool = true
var jumpTimes: int = 0
var canDash: bool = true

var isJumping: bool = false  # Variable to verify if flying
var isCombatMode: bool = false
var isSliding: bool = false
var isAttackFinished: bool = true
var isRolling: bool = false
var isDead: bool = false

var attackPoints: int = 3
var airAttackPoints: int = 2
var default_damage_melee : float

func _ready():
	animatedSprite.playing = true
	playerHitbox.get_node("CollisionShape2D").disabled = true

	animatedSprite.frames.set_animation_speed("attack1", PlayerStats.get("attack_speed"))
	animatedSprite.frames.set_animation_speed("attack2", PlayerStats.get("attack_speed"))
	animatedSprite.frames.set_animation_speed("attack3", PlayerStats.get("attack_speed"))
	default_damage_melee = playerHitbox.get("damage")

func _process(delta):
	if not isDead:
		if isAttackFinished or animatedSprite.animation == "air_attack_loop_down":
			motion.y += GRAVITY
		else:
			motion.y += (GRAVITY / 4)
		snapVector = (SNAP_DIRECTION * SNAP_LENGHT) if snap else Vector2.ZERO
		_flip_animatedsprite()
		_on_floor(delta) if is_on_floor() else _on_fall(delta)
		motion.y = _move()

func _move():
	return move_and_slide_with_snap(motion, snapVector, Vector2.UP, snap, 4, SLOPE_THRESHOLD).y

func _on_fall(delta: float) -> void:
	snap = true
	if isAttackFinished:
		# Allow Player move while falling
		if Input.get_action_strength("ui_left"):
			moveDirection = Vector2.LEFT
			motion = motion.move_toward(moveDirection * MAX_SPEED, ACCELERATION * delta)
		elif Input.get_action_strength("ui_right"):
			moveDirection = Vector2.RIGHT
			motion = motion.move_toward(moveDirection * MAX_SPEED, ACCELERATION * delta)
		else:
			animatedSprite.play("fall")
	#			motion = motion.move_toward(Vector2.ZERO, FRICCTION * delta)
	_actions_while_falling(delta)

func _actions_while_falling(delta: float) -> void:
	if jumpTimes < JUMP_TIMES_LIMIT:
		if Input.is_action_just_pressed("Jump") and canDoubleJump and PlayerStats.energy > 1:
			isJumping = true
			if isAttackFinished:
				animatedSprite.play("jump")
				UserInterface._StatsInterface.update_energy(-2)
				motion.y = JUMP_HEIGHT
				snap = true
			jumpTimes += 1
	if Input.is_action_just_pressed("AttackMelee"):
		if isAttackFinished and PlayerStats.get("energy") > 10:
			playerHitbox.get_node("CollisionShape2D").disabled = false
			isAttackFinished = false
			isCombatMode = true
			motion = Vector2.ZERO
			$Timer.start(5)
			_attack_while_falling()
		elif PlayerStats.get("energy") < 10:
			UserInterface._StatsInterface.play_animation("alert")

	elif Input.get_action_strength("RangedAttack"):
		if (isAttackFinished and not isSliding and PlayerStats.get("energy") > 25):
			$Timer.start(5)
			animatedSprite.play("shot_bow_jump")
			isAttackFinished = false
			isCombatMode = true
			motion = Vector2.ZERO
		elif PlayerStats.get("energy") < 25:
			UserInterface._StatsInterface.play_animation("alert")

func _attack_while_falling():
	if airAttackPoints == 2 and PlayerStats.get("energy") > 10:
		playerHitbox.damage *= 1.5
		animatedSprite.play("air_attack1")
		UserInterface._StatsInterface.update_energy(-10)
	elif airAttackPoints == 1 and PlayerStats.get("energy") > 15:
		playerHitbox.damage *= 1.75
		animatedSprite.play("air_attack2")
		UserInterface._StatsInterface.update_energy(-15)
	elif airAttackPoints == 0 and PlayerStats.get("energy") > 20:
		playerHitbox.damage *= 1
		animatedSprite.play("air_attack_loop_down")
		UserInterface._StatsInterface.update_energy(-20)
	else:
		isAttackFinished = true
		airAttackPoints = 2
		playerHitbox.damage = default_damage_melee

func _on_floor(delta: float) -> void:
	_update_variables()

	moveDirection.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if (moveDirection.x != 0) and isAttackFinished:
		_move_on_floor(delta)
	else:
		_idle(delta)

	_actions_while_floor()

func _actions_while_floor():
	# Jump
	if Input.get_action_strength("Jump"):
		if isAttackFinished and PlayerStats.energy > 0:
			isJumping = true
			UserInterface._StatsInterface.update_energy(-1)
			animatedSprite.play("jump")
			motion.y = JUMP_HEIGHT
			snap = true
		if PlayerStats.energy < 1:
			UserInterface._StatsInterface.play_animation("alert")
	elif Input.get_action_strength("AttackMelee"):
		if isAttackFinished and not isSliding and PlayerStats.get("energy") > 0:
			$Timer.start(5)
			
			isAttackFinished = false
			isCombatMode = true
			_attack_while_floor()
		elif PlayerStats.get("energy") < 5:
			UserInterface._StatsInterface.play_animation("alert")
		motion = Vector2.ZERO
	elif Input.get_action_strength("RangedAttack"):
		if (isAttackFinished and not isSliding and PlayerStats.get("energy") >= 25):
			$Timer.start(5)
			animatedSprite.play("shot_bow")
			isAttackFinished = false
			isCombatMode = true
			motion = Vector2.ZERO
		elif PlayerStats.get("energy") < 25:
			UserInterface._StatsInterface.play_alert_energy()

func _attack_while_floor():
	if attackPoints == 3 and PlayerStats.get("energy") > 5:
		animatedSprite.play("draw_sword")
	elif attackPoints == 2 and PlayerStats.get("energy") > 5:
		playerHitbox.get_node("CollisionShape2D").disabled = false
		UserInterface._StatsInterface.update_energy(-5)
		animatedSprite.play("attack1")
		playerHitbox.damage *= 1.25
	elif attackPoints == 1 and PlayerStats.get("energy") > 10:
		playerHitbox.get_node("CollisionShape2D").disabled = false
		UserInterface._StatsInterface.update_energy(-10)
		animatedSprite.play("attack2")
		playerHitbox.damage *= 1.50
	elif attackPoints == 0 and PlayerStats.get("energy") > 15:
		playerHitbox.get_node("CollisionShape2D").disabled = false
		UserInterface._StatsInterface.update_energy(-15)
		animatedSprite.play("attack3")
		playerHitbox.damage *= 1.50
	else:
		attackPoints = 3
		isAttackFinished = true

func _update_variables():
	_update_slope_angle()
	motion_angle = Vector2().angle_to_point(motion)
	snap = false
	canDoubleJump = true
	jumpTimes = 0
	animatedSprite.rotation_degrees = 0

func _idle(delta: float) -> void:
	if isAttackFinished:
		isSliding = false
		if isCombatMode:
			if ["hurt"].has(animatedSprite.animation):
				yield(animatedSprite, "animation_finished")
			animatedSprite.play("idle_w_sword")
		else:
			if ["wield_sword", "hurt"].has(animatedSprite.animation):
				yield(animatedSprite, "animation_finished")
			animatedSprite.play("idle_normal")
		motion = motion.move_toward(Vector2.ZERO, FRICCTION * delta)

func _move_on_floor(delta: float) -> void:
	if Input.get_action_strength("ui_down") and motion_angle < 0:
		isSliding = true
		animatedSprite.play("slide")
		animatedSprite.rotation_degrees = (slope_angle * moveDirection.x)
		if slope_angle >= 15:
			motion = motion.move_toward(moveDirection * SLIDE_SPEED, ACCELERATION * delta)
		else:
			motion = motion.move_toward(Vector2.ZERO, (FRICCTION / 4) * delta)
#	elif Input.is_action_just_pressed("Roll") and not isSliding:
#		isRolling = true
#		animatedSprite.play("roll")
#		animatedSprite.position.y = -12
#		motion = motion.move_toward(Vector2.ZERO, (FRICCTION/6) * delta)
	else:
		isSliding = false
#		if animatedSprite.animation == "roll":
#			yield(animatedSprite, "animation_finished")
		if isCombatMode:
			animatedSprite.play("run_w_sword")
		else:
			animatedSprite.play("run")
		motion = motion.move_toward(moveDirection * MAX_SPEED, ACCELERATION * delta)

func _update_slope_angle() ->void:
	slope_angle = rad2deg(acos(get_floor_normal().dot(Vector2.UP)))

func _flip_animatedsprite():
	if moveDirection == Vector2.LEFT:
		animatedSprite.flip_h = true
		idleDirection = Vector2.LEFT
		$Playerhitbox/CollisionShape2D.position.x = -25
		playerHitbox.hit_direction = idleDirection
	elif moveDirection == Vector2.RIGHT:
		animatedSprite.flip_h = false
		idleDirection = Vector2.RIGHT
		$Playerhitbox/CollisionShape2D.position.x = 25
		playerHitbox.hit_direction = idleDirection
	else:
		pass

func _on_AnimatedSprite_animation_finished():
	if ["draw_sword", "attack1", "attack2", "shot_bow_jump"].has(animatedSprite.animation):
		attackPoints -= 1
		isAttackFinished = true
		playerHitbox.get_node("CollisionShape2D").disabled = true
		playerHitbox.damage = default_damage_melee
	elif ["attack3", "shot_bow"].has(animatedSprite.animation):
		attackPoints = 2
		isAttackFinished = true
		playerHitbox.damage = default_damage_melee
		playerHitbox.get_node("CollisionShape2D").disabled = true
	elif ["air_attack1", "air_attack2"].has(animatedSprite.animation):
		airAttackPoints -= 1
		playerHitbox.damage = default_damage_melee
		isAttackFinished = true
		playerHitbox.get_node("CollisionShape2D").disabled = true
	elif animatedSprite.animation == "air_attack_loop_down":
		airAttackPoints = 2
		if is_on_floor():
			playerHitbox.damage *= 2
			animatedSprite.play("air_attack_end")
	elif animatedSprite.animation == "air_attack_end":
		isAttackFinished = true
		playerHitbox.get_node("CollisionShape2D").disabled = true
		playerHitbox.damage = default_damage_melee

	if animatedSprite.animation == "jump":
		animatedSprite.play("jump_state")

	if animatedSprite.animation == "roll":
		animatedSprite.position.y = -25
		isRolling = false
	if ["shot_bow", "shot_bow_jump"].has(animatedSprite.animation):
		_instance_arrow()

func _instance_arrow() -> void:
	if isCombatMode:
		UserInterface._StatsInterface.update_energy(-25)
		UserInterface._StatsInterface.update_arrows(-1)
		var arrow_instance = arrow.instance()
		arrow_instance.position = $ArrowPivot.global_position
		if idleDirection == Vector2.LEFT:
			arrow_instance.set("flip_h", true)
		arrow_instance.init(idleDirection, 450)
		get_tree().root.add_child(arrow_instance)

func _instance(start_position, is_slave):
	global_position = start_position

func _on_Timer_timeout():
	if isCombatMode:
		animatedSprite.play("wield_sword")
	isCombatMode = false
	attackPoints = 3
	airAttackPoints = 2
	playerHitbox.get_node("CollisionShape2D").disabled = true
	playerHitbox.damage = default_damage_melee

func _on_Hurtbox_area_entered(area: Area2D):
	if area.name == "Enemyhitbox" and not isDead:
		if ["draw_sword", "attack1", "attack2", "attack3", "shot_bow"].has(animatedSprite.animation):
			yield(animatedSprite, "animation_finished")
		animatedSprite.play("hurt")
		UserInterface._StatsInterface.update_health(-area.get("damage"))
	_on_dead()

func _on_dead():
	if PlayerStats.health <= 0:
		isDead = true
		PlayerStats.health = 0
		animatedSprite.play("dead")
		yield(animatedSprite, "animation_finished")


func _on_AnimatedSprite_frame_changed():
	pass # Replace with function body.
