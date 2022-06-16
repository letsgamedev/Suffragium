extends KinematicBody2D

var speed:float = 40
var left:float = 0.0
var right:float = 0.0
var direction:Vector2 = Vector2.ZERO setget ,_get_direction


func _get_direction():
	return Vector2(right - left,0)


func _ready():
	pass


func _physics_process(_delta):
	# warning-ignore:return_value_discarded
	move_and_slide(_get_direction()*speed, Vector2.UP)


func _input(event:InputEvent):
	if event is InputEventKey and not event.echo:
		if event.physical_scancode == KEY_D and event.pressed:
			right = 1.0
		else:
			right = 0.0
