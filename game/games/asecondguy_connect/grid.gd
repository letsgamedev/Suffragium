@tool
extends StaticBody2D

@export var tile_size := Vector2(25, 25):
	set = set_tile_size
@export var grid_size := Vector2(7, 6):
	set = set_grid_size
@export var grid_color := Color.BLACK:
	set = set_grid_color
@export var circle_size := .4:
	set = set_circle_size

# helper for global_to_grid_pos()
var _bounds := Rect2(Vector2(), grid_size)

@onready var _mouse_blocker := $MouseBlocker


func _ready():
	var shape := RectangleShape2D.new()
	shape.size.x = 1
	shape.size.y = grid_size.y * tile_size.y / 2
	for x in range(grid_size.x + 1):
		var node := CollisionShape2D.new()
		node.shape = shape
		node.position.x = x * tile_size.x
		node.position.y = shape.size.y
		add_child(node)
	_mouse_blocker.size = grid_size * tile_size


func set_tile_size(val: Vector2):
	tile_size = val
	update()


func set_circle_size(val: float):
	circle_size = val
	update()


func set_grid_size(val: Vector2):
	grid_size = val
	_bounds = Rect2(Vector2(), grid_size)
	update()


func set_grid_color(val: Color):
	grid_color = val
	update()


func _draw():
	_mouse_blocker.material.set_shader_parameter("grid_size", grid_size)
	_mouse_blocker.material.set_shader_parameter(
		"grid_color", Vector3(grid_color.r, grid_color.g, grid_color.b)
	)
	_mouse_blocker.material.set_shader_parameter("circle_size", circle_size)


func global_to_grid_pos(pos: Vector2):
	var floored := ((pos - global_position) / tile_size).floor()
	return floored


func is_in_grid(pos: Vector2) -> bool:
	return _bounds.has_point(pos)


func is_global_pos_in_grid(pos: Vector2):
	return _bounds.has_point(global_to_grid_pos(pos))
