extends "Enemy.gd"

const GRAVITY := 5
const FLOOR := Vector2(0,-1)

const STOMP_DIST := 12
const ACTIVATE_DIST := 60

var falling := false
var reset := true
var velocity := Vector2.ZERO

var fall_delay = 0
const fall_delay_max = 60




func _ready() -> void:
	set_physics_process(false)
	
	hp = 5
	SCORE = 125
	DAMAGE = 2

func _physics_process(delta):
	if hitstun > 0:
		hitstun -= 1
		visible = hitstun % 3
		return
	
	elif visible == false:
		visible = true
	
	
	
	if not falling:
	
		var player_pos = get_parent().get_parent().get_player_pos()
		var player_hor_dist = abs(player_pos.x - global_position.x)
		
		if player_hor_dist <= STOMP_DIST:
			falling = true
			$Sprite.frame = 2
		elif player_hor_dist <= ACTIVATE_DIST:
			$Sprite.frame = 1
		else:
			$Sprite.frame = 0
		
	
	else:
		if reset:
			velocity.y += GRAVITY
	
			if is_on_floor():
				reset = false
				var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
				SFX.play("stompE")
				get_parent().add_child(SFX)
				get_parent().get_parent().player.screen_shake(5)
				
		else:
			velocity.y -= GRAVITY
			
			if is_on_ceiling():
				reset = true
				falling = false

				
	velocity = move_and_slide_with_snap(velocity, Vector2(0,1), FLOOR)
