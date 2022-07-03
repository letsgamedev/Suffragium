extends RigidBody2D

var color := Color.green
var player_id := -1

var target_position: Vector2
var _picked := false


func _ready():
	apply_central_impulse(Vector2.DOWN * 500)


func _integrate_forces(state):
	if _picked:
		var move: Vector2 = target_position - global_position

		var result := Physics2DTestMotionResult.new()
		if !test_motion(move, true, 0.08, result):
			state.linear_velocity = move / state.step
		else:
			state.linear_velocity = move / state.step * result.collision_safe_fraction
			state.linear_velocity += result.collision_normal * result.collision_unsafe_fraction
			state.angular_velocity = 0


func _on_chip_input_event(_viewport, event, _shape_idx):
	if !event is InputEventMouseButton:
		return
	if event.pressed:
		pick()
	else:
		unpick()


func _input(event):
	if mode == MODE_STATIC:
		return
	if event is InputEventMouseButton:
		if !event.pressed:
			unpick()
	if event is InputEventMouseMotion:
		target_position = event.global_position


func _draw():
	var radius: float = $CollisionShape2D.shape.radius
	draw_circle(Vector2(), radius, color)
	draw_circle(Vector2(), radius - 2, color.darkened(0.5))
	draw_arc(Vector2(), radius - 3, 0.1, 2, 10, color.lightened(0.5))


func pick():
	_picked = true
	inertia = 1
	sleeping = false


func unpick():
	_picked = false
	sleeping = false


func set_mouse_control(val: bool):
	set_process_input(val)
	input_pickable = val
