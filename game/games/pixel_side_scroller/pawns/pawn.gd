extends KinematicBody2D

var speed: float = 80
var gravity: float = 9.8
var jump_force: float = 100.0
var jump_time: float = 0.2
var max_fall_speed: float = 2000

var left: float = 0.0
var right: float = 0.0
var jump: bool = false

onready var movement = $Movement


func _physics_process(delta):
	movement.do(delta)
	# warning-ignore:return_value_discarded
	move_and_slide(movement.velocity, Vector2.UP)
