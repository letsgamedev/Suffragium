tool
extends Line2D

const GRID_SIZE := Vector2(80, 78)

var grid_points := []
var _rng := RandomNumberGenerator.new()


func _ready():
	_rng.randomize()
	$Timer.start()
	clear_points()
	add_point(grid_points[0] * GRID_SIZE + GRID_SIZE / 2)
	for _i in range(grid_points.size() - 2):
		add_point(Vector2())
	_update_points()
	add_point(grid_points[-1] * GRID_SIZE + GRID_SIZE / 2)


func _update_points():
	for i in range(1, grid_points.size() - 1):
		var pos: Vector2 = (
			grid_points[i] * GRID_SIZE
			+ Vector2.ONE.rotated(deg2rad(_rng.randf_range(0, 360))) * 5
		)
		pos += GRID_SIZE / 2
		set_point_position(i, pos)
