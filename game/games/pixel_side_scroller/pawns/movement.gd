extends Node

var jumping: bool = false
var direction: Vector2 = Vector2.ZERO setget , _get_direction
var velocity: Vector2 = Vector2.ZERO

var _jumped: bool = false
var _jump_curve: Curve = load("res://games/pixel_side_scroller/pawns/jump_curve.tres")
var _jump_timer: Timer = Timer.new()

onready var _main = get_tree().current_scene
onready var _pawn = get_parent()


func _get_direction():
	return Vector2(_pawn.right - _pawn.left, 0)


func _ready():
	_init_jump_timer()


# Do movement logic
func do(delta):
	_jump(delta)
	# Gravity
	if _pawn.is_on_floor() and not jumping:
		velocity.y = 0
	elif not _pawn.is_on_floor() and not jumping:
		velocity.y = min(_pawn.max_fall_speed, velocity.y + (_pawn.gravity + delta))

	var input_direction: float = _get_direction().x
	if input_direction != 0.0:
		_main.ui.help_box.used_feature(PixelSideScrollerUtils.Features.MOVE)
	velocity.x = input_direction * _pawn.speed


# Handle jumps
func _jump(delta):
	# Reset state variables on "jump release"
	if not _pawn.jump and _jumped:
		_jumped = false
		jumping = false
	# Handle "hold jump" in air
	if not _pawn.is_on_floor():
		if _pawn.jump and _jumped:
			var curve_point: float = (
				(_jump_timer.wait_time - _jump_timer.time_left)
				/ _jump_timer.wait_time
			)
			if curve_point < 1.0:
				var curve_interpolate_value: float = _jump_curve.interpolate(curve_point)
				velocity.y += (-_pawn.jump_force * delta) * curve_interpolate_value
			else:
				jumping = false
	# Do "jump" if on the floor
	if _pawn.is_on_floor() and _pawn.jump and not _jumped:
		jumping = true
		_jumped = true
		velocity.y = -_pawn.jump_force
		_jump_timer.start()
		_main.ui.help_box.used_feature(PixelSideScrollerUtils.Features.JUMP)


func _init_jump_timer():
	_jump_timer.one_shot = true
	_jump_timer.wait_time = _pawn.jump_time
	_jump_timer.name = "JumpTimer"
	add_child(_jump_timer)
