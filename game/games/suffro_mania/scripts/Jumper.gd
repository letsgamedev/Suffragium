extends "Enemy.gd"

const SPEED := 100
const JUMP_POWER = -150
const GRAVITY := 5
const FLOOR := Vector2(0,-1)

export (Vector2) var direction = Vector2.LEFT

var velocity := Vector2.ZERO

var state = "idle"

var jump_timer = 90
var jump_timer_max = 80


var shoot_timer = 200
var shoot_timer_max = 90

var rng = RandomNumberGenerator.new()

var PROJECTILE = preload("res://games/suffro_mania/enemies/e_bullet.tscn")


func _ready() -> void:
	set_physics_process(false)
	
	hp = 4
	SCORE = 175


func _physics_process(delta):
	if hitstun > 0:
		hitstun -= 1
		visible = hitstun % 3
		return
	
	elif visible == false:
		visible = true
	
	
	
	match state:
		"idle":
			if direction == Vector2.LEFT:
				$AnimationPlayer.play("idle_left")
			elif direction == Vector2.RIGHT:
				$AnimationPlayer.play("idle_right")
			
			if jump_timer > 0:
				jump_timer -= 1
			
			else:
				state = "jump"
			
			
			if shoot_timer > 0 or jump_timer > 10:
				shoot_timer -= 1
	
			else:
				shoot()
				shoot_timer = shoot_timer_max + rng.randi_range(0,20)
			
		"jump":
			if direction == Vector2.LEFT:
				$AnimationPlayer.play("jump_left")
			elif direction == Vector2.RIGHT:
				$AnimationPlayer.play("jump_right")
			
			
		"air":
			if direction == Vector2.LEFT:
				$AnimationPlayer.play("air_left")
			elif direction == Vector2.RIGHT:
				$AnimationPlayer.play("air_right")
				
				
			if direction == Vector2.LEFT and is_on_wall():
				direction = Vector2.RIGHT
				
			elif direction == Vector2.RIGHT and is_on_wall():
				direction = Vector2.LEFT
			
			velocity.x += SPEED * direction.x * delta
			velocity.y += GRAVITY
	
			velocity = move_and_slide_with_snap(velocity, Vector2(0,1), FLOOR)
			
			if is_on_floor():
				state = "land"
			
		"land":
			if direction == Vector2.LEFT:
				$AnimationPlayer.play("landing_left")
			elif direction == Vector2.RIGHT:
				$AnimationPlayer.play("landing_right")
			
			velocity = Vector2.ZERO
	
	


func shoot() -> void:
	var instance = PROJECTILE.instance()
	get_parent().add_child(instance)
	instance.global_position = $Position2D.global_position
	instance.set_projectile_direction(get_parent().get_parent().get_player_pos())
	
	
	var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
	SFX.play("shootE")
	get_parent().add_child(SFX)


func jump() -> void:
	velocity.y += JUMP_POWER
	state = "air"
	
	var player_pos = get_parent().get_parent().get_player_pos()
	var player_hor_dist = player_pos.x - global_position.x
	
	if player_hor_dist <= 0 and direction == Vector2.RIGHT:
		direction = Vector2.LEFT
	elif  player_hor_dist > 0 and direction == Vector2.LEFT:
		direction = Vector2.RIGHT 
	
	var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
	SFX.play("jumpE")
	get_parent().add_child(SFX)
	

func landed() -> void:
	jump_timer = jump_timer_max + rng.randi_range(0,20)
	state = "idle"
	
