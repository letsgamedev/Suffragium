extends Node

var left: float = 0.0
var right: float = 0.0
var jump: bool = false

onready var pawn = get_parent()


func _input(event: InputEvent):
	if event is InputEventKey and not event.echo:
		if event.scancode == KEY_D or event.scancode == KEY_RIGHT:
			right = 1.0 if event.pressed else 0.0
		if event.scancode == KEY_A or event.scancode == KEY_LEFT:
			left = 1.0 if event.pressed else 0.0
		if event.scancode == KEY_SPACE or event.scancode == KEY_W or event.scancode == KEY_UP:
			jump = event.pressed
