extends KinematicBody

var speed: float = 5.0
onready var input_handler = $InputHandler


func _process(_delta):
	var move_direction: Vector3 = Vector3(
		input_handler.move_direction.x, 0, input_handler.move_direction.y
	)
	var move_velocity: Vector3 = move_direction.normalized() * speed
# warning-ignore:return_value_discarded
	move_and_slide(move_velocity, Vector3(0, 1, 0))
