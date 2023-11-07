extends Node

const FALL_TIME_THRESHOLD: float = 0.2
var coyote_time: float = 0.15
var air_time: float = 0.0

var speed: float = 80
var gravity: float = 9.8
var jump_force: float = 100.0
var jump_time: float = 0.2
var max_fall_speed: float = 2000

var jumping: bool = false
var direction: Vector2 = Vector2.ZERO:
	get = _get_direction
var velocity: Vector2 = Vector2.ZERO

var _jumped: bool = false
var _jump_curve: Curve = load("res://games/pixel_side_scroller/pawns/jump_curve.tres")
var _jump_timer: Timer = Timer.new()

var _is_falling = false
var _fall_timer = 0

@onready var _main = get_tree().current_scene
@onready var _pawn = get_parent()


func _get_direction():
	return Vector2(_pawn.input.right - _pawn.input.left, 0)


func _ready():
	_init_jump_timer()


# Do movement logic
func do(delta):
	_jump(delta)
	# Gravity
	if _pawn.is_on_floor() and not jumping:
		velocity.y = 1
	elif not _pawn.is_on_floor() and not jumping:
		velocity.y = min(max_fall_speed, velocity.y + (gravity + delta))

	var input_direction: float = _get_direction().x
	if input_direction != 0.0:
		_main.ui.help_box.used_feature(PixelSideScrollerUtils.Features.MOVE)
	velocity.x = input_direction * speed
	if _is_falling and _pawn.is_on_floor():
		_pawn.on_ground_hit()
	_update_falling_state(delta)

	# warning-ignore:return_value_discarded
	_pawn.set_velocity(velocity)
	_pawn.set_up_direction(Vector2.UP)
	_pawn.move_and_slide()
	#_pawn.velocity


# Handle jumps
func _jump(delta):
	# Reset state variables on "jump release"
	if not _pawn.input.jump and _jumped:
		_jumped = false
		jumping = false

	if _pawn.is_on_floor():
		# Reset time falling
		air_time = 0.0
	else:
		# Add time falling
		air_time += delta
		# Handle "hold jump" in air
		if _pawn.input.jump and _jumped:
			var curve_point: float = (
				(_jump_timer.wait_time - _jump_timer.time_left) / _jump_timer.wait_time
			)
			if curve_point < 1.0:
				var curve_interpolate_value: float = _jump_curve.sample(curve_point)
				velocity.y += (-jump_force * delta) * curve_interpolate_value
			else:
				jumping = false

	# Do "jump" if on the floor (or still in coyote time)
	if _pawn.input.jump and not _jumped and air_time <= coyote_time:
		jumping = true
		_jumped = true
		velocity.y = -jump_force
		_jump_timer.start()
		_main.ui.help_box.used_feature(PixelSideScrollerUtils.Features.JUMP)
		_pawn.on_jump()


func _update_falling_state(delta):
	if velocity.y <= 0 or _pawn.is_on_floor():
		_fall_timer = 0
	else:
		_fall_timer += delta
	_is_falling = _fall_timer > FALL_TIME_THRESHOLD


func _init_jump_timer():
	_jump_timer.one_shot = true
	_jump_timer.wait_time = jump_time
	_jump_timer.name = "JumpTimer"
	add_child(_jump_timer)
