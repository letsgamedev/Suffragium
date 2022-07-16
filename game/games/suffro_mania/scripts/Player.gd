extends KinematicBody2D

onready var anim := $AnimationPlayer

const GRAVITY := 7
const MAX_SPEED := 75
const ACCELERATION := 20

var JUMP_POWER := -190
var FLOOR := Vector2(0,-1)


var spritedir := Vector2.RIGHT
var velocity := Vector2()
var friction = false

var shoottimer := 0
var SHOOTTIMER_MAX := 11


var max_hp := 20
var hp : int = max_hp
var hitstun = 0
var hitstun_max = 60

var can_flip = false
var flipped = false


const SHAKE_DECAY_RATE := 5.0
var shake_strength := 0.0

var rng = RandomNumberGenerator.new()

enum STATES {
	DEFAULT,
	DEAD
}

var state = STATES.DEFAULT 


const PROJECTILE = preload("res://games/suffro_mania/Bullet.tscn")
var projectiles = []

var normalSprites = preload("res://games/suffro_mania/assets/sprites/player.png")
var shootSprites = preload("res://games/suffro_mania/assets/sprites/player-shoot.png")

var deathExplosion = preload("res://games/suffro_mania/Death_explosion.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rng.randomize()
	add_to_group("PLAYER")
	
	yield(get_tree(), "idle_frame")
	
	for i in 100:
		var projectile = PROJECTILE.instance()
		get_parent().add_child(projectile)
		projectiles.append(projectile)



func _physics_process(delta: float) -> void:
	
	if state == STATES.DEFAULT:
		movement_loop()
		control_loop()
		animation_loop()
		damage_loop()
		
		shake_strength = lerp(shake_strength, 0, SHAKE_DECAY_RATE * delta)
		$Camera2D.offset = get_random_offset()



func movement_loop() -> void:
	friction = false
	
	# Schlittern und Anlauf
	if is_on_floor() and friction:
		velocity.x = lerp(velocity.x, 0, 0.2)
	else:
		velocity.x = lerp(velocity.x, 0, 0.1)
	
	
	if flipped:
		velocity.y -= GRAVITY
	else:
		velocity.y += GRAVITY
	
	velocity = move_and_slide_with_snap(velocity, Vector2(0,1),FLOOR)



func control_loop() -> void:
	# Movement
	if Input.is_action_pressed("D") and not Input.is_action_pressed("A"):
		spritedir = Vector2.RIGHT
		velocity.x = min(velocity.x + ACCELERATION, MAX_SPEED)
	
	elif Input.is_action_pressed("A") and not Input.is_action_pressed("D"):
		spritedir = Vector2.LEFT
		velocity.x = max(velocity.x - ACCELERATION, -MAX_SPEED)	
	
	elif Input.is_action_pressed("A") and Input.is_action_pressed("D"):
		velocity.x = 0

	else:
		friction = true
	
		
	# Jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_POWER

	elif Input.is_action_just_released("ui_accept") and velocity.y <= JUMP_POWER/2:
		velocity.y = JUMP_POWER/2
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("jump")
		get_parent().add_child(SFX)
	
	
	
	# Flip
	if Input.is_action_just_pressed("W") and can_flip:
		flipped = !flipped
		FLOOR *= -1
		JUMP_POWER *= -1
#		$Camera2D.zoom.y *= -1
		
		
	# Shooting
	
	if shoottimer > 0:
		shoottimer -= 1
	
	if Input.is_action_just_pressed("K"):
		shoottimer = 0
	
	if shoottimer < 3 and $Sprite.texture == shootSprites:
		$Sprite.texture = normalSprites
	
	if Input.is_action_pressed("K") and shoottimer == 0:
		shoottimer = SHOOTTIMER_MAX
		
		var projectile = projectiles.pop_front()
		
		projectile.set_physics_process(true)
		projectile.show()
		
		projectile.set_projectile_direction(spritedir)
	
		projectile.position = $Position2D.global_position
		
		projectiles.append(projectile)
		
		
		var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("laserGun")
		get_parent().add_child(SFX)
		
		
		$Sprite.texture = shootSprites



func animation_loop() -> void:
	# Animation
	
	# flipped
	if flipped:
		$Sprite.flip_v = true
	else:
		$Sprite.flip_v = false
	
	
	if not is_on_floor() and spritedir == Vector2.RIGHT:
		anim.play("jump_right")
	elif not is_on_floor() and spritedir == Vector2.LEFT:
		anim.play("jump_left")
	
	elif velocity.x == 0 or friction:
		if spritedir == Vector2.RIGHT:
			anim.play("stand_right")
		elif spritedir == Vector2.LEFT:
			anim.play("stand_left")
		else:
			anim.stop()
	
	elif velocity.x > 0 and spritedir == Vector2.RIGHT:
		anim.play("walk_right")
	
	elif velocity.x < 0 and spritedir == Vector2.LEFT:
		anim.play("walk_left")
	
	
	
	else:
		anim.stop()




func damage_loop() -> void:
	if hp <= 0:
		var instance = deathExplosion.instance()
		get_parent().add_child(instance)
		instance.position = global_position
		state = STATES.DEAD
		
		visible = false
		
		var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("explode")
		get_parent().add_child(SFX)
		
	if hitstun > 0:
		hitstun -= 1
		$Sprite.visible = hitstun % 2
		return
	
	elif not $Sprite.visible:
		$Sprite.visible = true
	
	
		
	for area in $HurtBox.get_overlapping_areas():
		if area.get_parent().get("DAMAGE") != null:
			hp -= area.get_parent().DAMAGE
			hitstun = hitstun_max
			
			var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
			SFX.play("damage")
			get_parent().add_child(SFX)
			
			
			get_parent().update_health()
			
			# Knockback
			velocity.x += spritedir.x * MAX_SPEED * -1
			velocity.y += JUMP_POWER / 2 
			
		if area.get("DAMAGE") != null:
			hp -= area.DAMAGE
			hitstun = hitstun_max
					
			var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
			SFX.play("damage")
			get_parent().add_child(SFX)
			
			
			get_parent().update_health()
			
			# Knockback
			velocity.x += spritedir.x * MAX_SPEED * -1
			velocity.y += JUMP_POWER / 2 
		
				
	



func _on_RoomDetector_area_entered(area: Area2D) -> void:
	if area.is_in_group("ROOM"):
		var collision_shape : CollisionShape2D = area.get_node("CollisionShape2D")
		var size = collision_shape.shape.extents
		
		
		$Camera2D.limit_top = collision_shape.global_position.y - size.y
		$Camera2D.limit_left = collision_shape.global_position.x - size.x
		$Camera2D.limit_bottom = collision_shape.global_position.y + size.y
		$Camera2D.limit_right = collision_shape.global_position.x + size.x
		
		
		position += spritedir * 8




func screen_shake(strength) -> void:
	shake_strength = strength
	
func get_random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)
