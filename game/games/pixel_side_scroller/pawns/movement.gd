extends Node

var jumped: bool = false
var jump_curve: Curve = load("res://games/pixel_side_scroller/pawns/jump_curve.tres")
var jump_timer: Timer = Timer.new()

var jumping: bool = false
var direction: Vector2 = Vector2.ZERO setget , _get_direction
var velocity: Vector2 = Vector2.ZERO

onready var pawn = get_parent()


func _get_direction():
	return Vector2(pawn.right - pawn.left, 0)


func _ready():
	_init_jump_timer()


# Do movement logic
func do(delta):
	_jump(delta)
	# Gravity
	if pawn.is_on_floor() and not jumping:
		velocity.y = 0
	elif not pawn.is_on_floor() and not jumping:
		velocity.y = min(pawn.max_fall_speed, velocity.y + (pawn.gravity + delta))

	velocity.x = _get_direction().x * pawn.speed


# Handle jumps
func _jump(delta):
	# Reset state variables on "jump release"
	if not pawn.jump and jumped:
		jumped = false
		jumping = false
	# Handle "hold jump" in air
	if not pawn.is_on_floor():
		if pawn.jump and jumped:
			var curve_point: float = (
				(jump_timer.wait_time - jump_timer.time_left)
				/ jump_timer.wait_time
			)
			if curve_point < 1.0:
				var curve_interpolate_value: float = jump_curve.interpolate(curve_point)
				velocity.y += (-pawn.jump_force * delta) * curve_interpolate_value
			else:
				jumping = false
	# Do "jump" if on the floor
	if pawn.is_on_floor() and pawn.jump and not jumped:
		jumping = true
		jumped = true
		velocity.y = -pawn.jump_force
		jump_timer.start()


func _init_jump_timer():
	jump_timer.one_shot = true
	jump_timer.wait_time = pawn.jump_time
	jump_timer.name = "JumpTimer"
	add_child(jump_timer)
