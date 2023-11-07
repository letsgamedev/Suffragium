extends "res://games/pixel_side_scroller/pawns/pawn.gd"

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(_delta):
	_animation()
	_flip()


func _animation() -> void:
	if movement.direction.x == 0 or not is_on_floor():
		animation_player.play("stand")
	else:
		animation_player.play("run")


func _flip() -> void:
	if movement.direction.x > 0:
		$Sprite2D.flip_h = false
	elif movement.direction.x < 0:
		$Sprite2D.flip_h = true


func on_ground_hit() -> void:
	$Sounds/LandSound.play()


func on_jump() -> void:
	$Sounds/JumpSound.play()


func on_kill() -> void:
	$Sounds/HitSound.play()
