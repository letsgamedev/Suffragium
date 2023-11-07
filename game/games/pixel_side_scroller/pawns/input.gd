extends Node

var left: float = 0.0
var right: float = 0.0
var jump: bool = false

@onready var pawn = get_parent()


func _input(event: InputEvent):
	if event is InputEventKey and not event.echo:
		if event.keycode == KEY_D or event.keycode == KEY_RIGHT:
			right = 1.0 if event.pressed else 0.0
		if event.keycode == KEY_A or event.keycode == KEY_LEFT:
			left = 1.0 if event.pressed else 0.0
		if event.keycode == KEY_SPACE or event.keycode == KEY_W or event.keycode == KEY_UP:
			jump = event.pressed
