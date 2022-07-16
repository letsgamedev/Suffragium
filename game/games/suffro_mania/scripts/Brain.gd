extends "Enemy.gd"

const SPEED := 40
const GRAVITY := 5
const FLOOR := Vector2(0,-1)

export (Vector2) var direction = Vector2.LEFT

var velocity := Vector2.ZERO

enum STATES {
	APPEAR,
	IDLE,
	CHASE,
	STOMP
}

var state = STATES.APPEAR


var state_timer := 40
var state_timer_max := 40

var move_timer := 30
var move_timer_max := 30

var falling := false
var reset := true
var reset_y_pos = 0

var shoot_timer := 100
var shoot_timer_max := 60

var t = 0

var rng = RandomNumberGenerator.new()

const PROJECTILE = preload("res://games/suffro_mania/enemies/e_bullet.tscn")


func _ready() -> void:
	set_physics_process(false)
	
	add_to_group("BOSS")
	
	hp = 20
	DAMAGE = 3
	SCORE = 10000


func _physics_process(delta):
	t += delta
		
	if hitstun > 0:
		hitstun -= 1
		visible = hitstun % 3
	
	elif visible == false:
		visible = true
	
	
	if direction == Vector2.ZERO:
		direction.x = rng.randi_range(-1,1)
	
	
	match state:
		STATES.IDLE:
			if direction.x < 0 and is_on_wall():
				direction = Vector2.RIGHT
				
			elif direction.x > 0 and is_on_wall():
				direction = Vector2.LEFT
						
			elif rng.randi_range(0,150) == 1:
				direction *= -1 
				
			velocity.y = sin(t) * 10

			if direction.x < 0:
				$AnimationPlayer.play("walk_left")
			else:
				$AnimationPlayer.play("walk_right")
			
			
			if state_timer > 0:
				state_timer -= 1
			
			else:
				rng.randomize()
				var next_state = rng.randi_range(0,2)
				
				state_timer = state_timer_max
				
				match next_state:
					0:
						state = STATES.IDLE
					1:
						state = STATES.CHASE
					2:
						state = STATES.STOMP
						move_timer = 30
						reset_y_pos = global_position.y

			
		STATES.CHASE:
			var player_pos = get_parent().get_parent().get_player_pos()
			var player_hor_dist = player_pos.x - global_position.x
			
			velocity.y = sin(t) * 10
			
			if move_timer > 0:
				move_timer -= 1
			else:
				if player_hor_dist <= 0 and direction == Vector2.RIGHT:
					direction = Vector2.LEFT
					move_timer = move_timer_max + rng.randi_range(0,20)
				elif  player_hor_dist > 0 and direction == Vector2.LEFT:
					direction = Vector2.RIGHT 
					move_timer = move_timer_max + rng.randi_range(0,20)

			
			if shoot_timer > 0:
				shoot_timer -= 1
				if direction.x < 0:
					$AnimationPlayer.play("walk_left")
				else:
					$AnimationPlayer.play("walk_right")
				
			else:
				$AnimationPlayer.play(("shoot"))
					
				velocity = Vector2.ZERO
				
		
		
		
		STATES.STOMP:
			$AnimationPlayer.play("stomp")
			
			var player_pos = get_parent().get_parent().get_player_pos()
			var player_hor_dist = player_pos.x - global_position.x
			
			if player_hor_dist <= 0 and direction == Vector2.RIGHT:
				direction = Vector2.LEFT

			elif player_hor_dist > 0 and direction == Vector2.LEFT:
				direction = Vector2.RIGHT 
			
			
			if player_hor_dist <= 10 and player_hor_dist >= -10:
				velocity.y -= GRAVITY
				yield(get_tree().create_timer(0.05), "timeout")
				falling = true
			
			
			if falling:
				direction.x = 0
				if reset:
					velocity.y += GRAVITY
					
					if is_on_floor():
						var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
						SFX.play("stompE")
						get_parent().add_child(SFX)
						
						get_parent().get_parent().player.screen_shake(15)
						
						reset = false
					
				else:
					yield(get_tree().create_timer(0.5), "timeout")
					velocity.y -= GRAVITY
					
					if global_position.y <= reset_y_pos:
						reset = true
						falling = false
						state = STATES.IDLE
						velocity.y = 0
			
			else:
				velocity.y = sin(t) * 10
		
		STATES.APPEAR:
			velocity.y = GRAVITY * 3
			direction.x = 0
			
			if position.y >= 270:
				state = STATES.IDLE
				velocity.y = 0
				var music = get_parent().get_parent().get_node("BackgroundMusic")
				
				music.stream = load("res://games/suffro_mania/assets/music/Boss Fight Bounce.mp3")
				music.play()
				
				music.volume_db = -20

	
	velocity.x = SPEED * direction.x
	
	velocity = move_and_slide_with_snap(velocity, Vector2(0,1), FLOOR)
	
	
func shoot() -> void:		
	var instance = PROJECTILE.instance()
	get_parent().add_child(instance)
	instance.global_position = $Position2D.global_position
	instance.set_projectile_direction(get_parent().get_parent().get_player_pos())
	
	instance = PROJECTILE.instance()
	get_parent().add_child(instance)
	instance.global_position = $Position2D2.global_position
	instance.set_projectile_direction(get_parent().get_parent().get_player_pos())
	
	var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
	SFX.play("shootE")
	get_parent().add_child(SFX)
	
	if rng.randi_range(0,3) == 1:
		state = STATES.IDLE




func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "shoot":
		shoot_timer = shoot_timer_max + rng.randi_range(0,15)




func _on_Shield_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("player_projectiles"):
		area.kill()
