extends "Enemy.gd"

const SPEED := 50
const GRAVITY := 5
const FLOOR := Vector2(0,-1)

export (Vector2) var direction = Vector2.LEFT

var velocity := Vector2.ZERO

func _ready() -> void:
	set_physics_process(false)
	
	hp = 3
	SCORE = 200
	DAMAGE = 3

func _physics_process(delta):
	if hitstun > 0:
		hitstun -= 1
		visible = hitstun % 3
		return
	
	elif visible == false:
		visible = true
	
	
	if direction == Vector2.LEFT:
		$AnimationPlayer.play("fly_left")
	elif direction == Vector2.RIGHT:
		$AnimationPlayer.play("fly_right")
	
	
	if direction == Vector2.LEFT and is_on_wall() or direction == Vector2.LEFT and not $Left.is_colliding():
		direction = Vector2.RIGHT
		
	elif direction == Vector2.RIGHT and is_on_wall() or direction == Vector2.RIGHT and not $Right.is_colliding():
		direction = Vector2.LEFT
	
	
	velocity.x = SPEED * direction.x
	
	velocity.y += GRAVITY
	
	velocity = move_and_slide_with_snap(velocity, Vector2(0,1), FLOOR)


func _on_Shield_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("player_projectiles"):
		area.kill()
