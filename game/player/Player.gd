extends KinematicBody2D

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")

const MAX_SPEED = 500
const ACCELERATION = 4000
const FRICTION = 4000

var velocity = Vector2.ZERO

func _ready():
	animationTree.active = true

func _physics_process(delta):
	# Movement
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("right")-Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down")-Input.get_action_strength("up")
	input_vector = input_vector.normalized()

	# Animaton
	if input_vector != Vector2.ZERO:
		animationTree.set("parameters/Move/blend_position", input_vector)
		animationState.travel("Move")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	velocity = move_and_slide(velocity, Vector2(0, 0))
