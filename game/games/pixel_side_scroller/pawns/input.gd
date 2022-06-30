extends Node

onready var pawn = get_parent()


func _input(event: InputEvent):
	if event is InputEventKey and not event.echo:
		if event.physical_scancode == KEY_D:
			if event.pressed:
				pawn.right = 1.0
			else:
				pawn.right = 0.0
		if event.physical_scancode == KEY_A:
			if event.pressed:
				pawn.left = 1.0
			else:
				pawn.left = 0.0
		if event.physical_scancode == KEY_SPACE:
			if event.pressed:
				pawn.jump = true
			else:
				pawn.jump = false
