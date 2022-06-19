extends "res://games/pixel_side_scroller/pawns/pawn.gd"

onready var animation_player: AnimationPlayer = $AnimationPlayer


func _process(_delta):
	if _get_direction().x == 0:
		animation_player.play("stand")
	else:
		animation_player.play("run")
