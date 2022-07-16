extends "Enemy.gd"

const SPEED = 50

export (Vector2) var direction = Vector2.LEFT

var move = Vector2(0,0)
var rotating: int = 1



func _ready() -> void:
	if direction == Vector2.LEFT:
		$AnimationPlayer.play("spin_left")
	else:
		$AnimationPlayer.play("spin_right")
	
	set_physics_process(false)
	
	hp = 2
	SCORE = 100


func _physics_process(delta):
	if hitstun > 0:
		hitstun -= 1
		visible = hitstun % 3
		return
	
	elif visible == false:
		visible = true
	
	
	
	if rotating:
		rotation = lerp_angle(rotation, move.angle(), 0.1)
		rotating -= 1
		return
	
	var col := move_and_collide(move * SPEED * direction.x * delta)
	
	if col and col.normal.rotated(PI/2).dot(move) < 0.5:
		rotating = 4
		move = col.normal.rotated(PI/2)
		return
	
	var pos := position
	col = move_and_collide(move.rotated(PI/2) * 15)
	if not col:
		for i in 10:
			position = pos
			rotate(PI/32)
			move = move.rotated(PI/32)
			col = move_and_collide(move.rotated(PI/2) * 15)
			
			if col:
				move = col.normal.rotated(PI/2)
				rotation = move.angle()
				break
	else:
		move = col.normal.rotated(PI/2)
		rotation = move.angle()
		
	
	
