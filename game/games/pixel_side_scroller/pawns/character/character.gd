extends "res://games/pixel_side_scroller/pawns/pawn.gd"

onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(_delta):
	_animation()
	_flip()


func _animation() -> void:
	if movement.direction.x == 0:
		animation_player.play("stand")
	else:
		animation_player.play("run")


func _flip() -> void:
	if movement.direction.x > 0:
		$Sprite.flip_h = false
	elif movement.direction.x < 0:
		$Sprite.flip_h = true
