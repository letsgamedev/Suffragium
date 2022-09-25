extends KinematicBody2D

var speed: float = 80
var gravity: float = 9.8
var jump_force: float = 100.0
var jump_time: float = 0.2
var coyote_time: float = 0.15
var max_fall_speed: float = 2000

var left: float = 0.0
var right: float = 0.0
var fall_time: float = 0.0
var jump: bool = false

onready var movement = $Movement
onready var _main = get_tree().current_scene


func _physics_process(delta):
	if self.position.y > 100:
		_main.kill_player()
		return
	movement.do(delta)
	# warning-ignore:return_value_discarded
	move_and_slide(movement.velocity, Vector2.UP)


func disable():
	$CollisionShape2D.set_deferred("disabled", true)


func enable():
	$CollisionShape2D.disabled = false
