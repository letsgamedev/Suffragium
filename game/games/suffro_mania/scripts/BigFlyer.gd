extends "Enemy.gd"

const SPEED := 30
const GRAVITY := 5
const FLOOR := Vector2(0,-1)

export (Vector2) var direction = Vector2.LEFT

var velocity := Vector2.ZERO


var shoot_timer = 100
var shoot_timer_max = 40

var rng = RandomNumberGenerator.new()

const PROJECTILE = preload("res://games/suffro_mania/enemies/e_bullet.tscn")


func _ready() -> void:
	rng.randomize()
	set_physics_process(false)
	
	hp = 6
	SCORE = 550


func _physics_process(delta):
	if hitstun > 0:
		hitstun -= 1
		visible = hitstun % 3
		return
	
	elif visible == false:
		visible = true
	
	
	
	if shoot_timer > 0:
		shoot_timer -= 1
		
		if direction.x < 0:
			$AnimationPlayer.play("walk_left")
		else:
			$AnimationPlayer.play("walk_right")
		
		if direction.x < 0 and is_on_wall():
			direction = Vector2.RIGHT
			
		elif direction.x > 0 and is_on_wall():
			direction = Vector2.LEFT
		
		
		elif rng.randi_range(0,100) == 1:
			direction *= -1 
			direction.y = rng.randf_range(-0.5,1)

		
		
		velocity.x = SPEED * direction.x
		velocity.y = SPEED * direction.y
	
	else:
		var player_pos = get_parent().get_parent().get_player_pos()
		var player_hor_dist = player_pos.x - global_position.x

		if direction.x <= 0 and player_hor_dist > 0:
			shoot_timer = shoot_timer_max * 0.75
			return
		if direction.x > 0 and player_hor_dist <= 0:
			shoot_timer = shoot_timer_max * 0.75
			return
		
		if direction == Vector2.LEFT:
			$AnimationPlayer.play("shoot_left")
		else:
			$AnimationPlayer.play("shoot_right")
	
	
	
	
	
	velocity = move_and_slide_with_snap(velocity, Vector2(0,1), FLOOR)
	
	
func shoot() -> void:		
	var instance = PROJECTILE.instance()
	get_parent().add_child(instance)
	instance.global_position = $Position2D.global_position
	instance.set_projectile_direction(get_parent().get_parent().get_player_pos())
	
	
	var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
	SFX.play("shootE")
	get_parent().add_child(SFX)

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "shoot_left" or anim_name == "shoot_right":
		shoot_timer = shoot_timer_max + rng.randi_range(0,15)

