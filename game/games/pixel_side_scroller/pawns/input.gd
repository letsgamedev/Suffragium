extends Node

onready var pawn = get_parent()


func _input(event: InputEvent):
	if event is InputEventKey and not event.echo:
		if event.scancode == KEY_D or event.scancode == KEY_RIGHT:
			pawn.right = 1.0 if event.pressed else 0.0
		if event.scancode == KEY_A or event.scancode == KEY_LEFT:
			pawn.left = 1.0 if event.pressed else 0.0
		if event.scancode == KEY_SPACE:
			pawn.jump = event.pressed
