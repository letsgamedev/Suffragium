extends Node2D

const CHIPSCRIPT := preload("res://games/asecondguy_connect/chip.gd")
const CONNECTSCRIPT := preload("res://games/asecondguy_connect/connect.gd")

export var player_id := 1

var chip: CHIPSCRIPT
var _curve := Curve2D.new()
var _goal_position := Vector2()
var _picked := false

onready var _chips_node := $"../Chips"
onready var _grid := $"../Grid"
onready var _game: CONNECTSCRIPT = $".."
onready var _timer := $Timer
onready var _pickup_timer := $PickupTimer


func _ready():
	set_process(false)
	seed(hash(str(OS.get_unix_time(), get_instance_id())))


func _process(_delta):
	if _is_chip_stopped() and !_picked:
		_start_pickup()
	if _picked:
		var pos = (
			(_timer.wait_time - _timer.time_left)
			/ _timer.wait_time
			* _curve.get_baked_length()
		)
		chip.target_position = _curve.interpolate_baked(pos, true)
		if is_equal_approx(pos, _curve.get_baked_length()):
			_unpick()


func _on_chip_spawn(new_chip: CHIPSCRIPT):
	if new_chip.player_id == player_id:
		chip = new_chip
		chip.set_mouse_control(false)
		_choose_goal()
		set_process(true)
		_pickup_timer.start()


# drawing the path for debugging
#func _draw():
#	var points := _curve.get_baked_points()
#	for i in range(points.size() - 1):
#		draw_line(points[i], points[i + 1], Color.red)


func _choose_goal():
	var field = _game.fallen_chips

	# find possible columns.
	# better columns will be added more often and therefore are more likely
	var possible_columns := []
	for i in range(field.size()):
		if field[i][0] != null:
			continue  # can't choose a column that is full
		possible_columns.push_back(i)
		# find the lowest position in the column
		var y := 0
		while true:
			if !_grid.is_in_grid(Vector2(i, y + 1)):
				break
			if field[i][y] != null:
				break
			y += 1
		var pos := Vector2(i, y)
		# positions with more chips in a line next to them are likely better
		for axis in [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(-1, 1)]:
			var run := 0
			run += _game.mesure_chip_run(pos, axis, player_id)
			run += _game.mesure_chip_run(pos, -axis, player_id)
			if run >= 3:
				run *= 100
			else:
				run *= 2
			for _j in range(run):
				possible_columns.push_back(i)

	# choose a column and its global position
	var column = possible_columns[randi() % possible_columns.size()]
	var column_x = _grid.tile_size.x * column + _grid.tile_size.x / 2 + _grid.position.x
	_curve.clear_points()
	_curve.add_point(Vector2(column_x, _grid.global_position.y), Vector2(0, -2 * _grid.tile_size.y))


# finish setting up the curve and set the chip to pickup
func _start_pickup():
	_curve.add_point(
		Vector2(chip.position.x, _grid.global_position.y),
		Vector2(),
		Vector2(0, -2 * _grid.tile_size.y),
		0
	)
	_curve.add_point(chip.position, Vector2(), Vector2(), 0)
	_picked = true
	chip.pick()
	_timer.start()
	update()


# reset everything and let the chip fall
func _unpick():
	_picked = false
	chip.unpick()
	set_process(false)
	_curve.clear_points()
	update()


func _is_chip_stopped():
	if !_pickup_timer.time_left == 0:
		return false
	return chip.linear_velocity.length() < 5 or chip.sleeping
