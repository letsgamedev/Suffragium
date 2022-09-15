extends Node2D

enum Direction { UP, DOWN, LEFT, RIGHT }
enum ColorScheme { CLASSIC, FIREFLY, MATCHSTICK, RAINBOW }

const COLORS = {
	APPLE_COLOR = Color(1, 0, 0),
	SNAKE_COLOR = Color(0.016, 1, 0),
	FIREFLY_START = Color(1, 0.89, 0.35),
	FIREFLY_END = Color(0.44, 0.4, 0.12),
	MATCHSTICK_HEAD = Color(0.66, 0.22, 0),
	MATCHSTICK_STICK = Color(0.86, 0.66, 0.28),
	RED = Color(1, 0, 0),
	YELLOW = Color(1, 1, 0),
	GREEN = Color(0, 1, 0),
	CYAN = Color(0, 1, 1),
	BLUE = Color(0, 0, 1),
	PURPLE = Color(0.2, 0, 0.35),
}

export var tile_count: int = 22
export var white_space: float = 80.0

var color_scheme: int = ColorScheme.CLASSIC

var _tile_size: int = 0

var _snake: Array = []
var _direction = Direction.RIGHT
var _input_stack = []
var _apple_pos := Vector2()

var _score: int = 0
var _high_score: int = 0

var _collected_delta: float = 0.0
var _game_paused: bool = false

onready var _main = get_tree().get_current_scene()


func _ready():
	_set_game_paused(true)
	randomize()
	_calc_tile_size()
	_set_playfield()
	_set_snake()
	_set_apple()


func _process(_delta):
	_collected_delta += _delta
	# TODO: This should scale over time/score
	var move_time = 0.067
	while _collected_delta >= move_time:
		_collected_delta -= move_time
		_turn_snake()
		var new_head_pos = _move_snake()
		var collision = _check_for_collision(new_head_pos)
		if collision:
			_game_over()
		else:
			_check_for_apple(new_head_pos)
		redraw()


func _draw():
	_draw_snake()
	_draw_apple()


func _input(_event):
	# Limit the input stack to 2 elements, that's enough for quick turns
	if _input_stack.size() > 1:
		return

	# Append current input (if any)
	if Input.is_action_just_pressed("ui_up"):
		_input_stack.append(Direction.UP)
	elif Input.is_action_just_pressed("ui_down"):
		_input_stack.append(Direction.DOWN)
	elif Input.is_action_just_pressed("ui_left"):
		_input_stack.append(Direction.LEFT)
	elif Input.is_action_just_pressed("ui_right"):
		_input_stack.append(Direction.RIGHT)
	else:
		return

	# Unpause the game
	_set_game_paused(false)


func redraw():
	update()  # triggers NOTIFICATION_DRAW of CanvasItem / _draw()


func _calc_tile_size():
	var spacing = Vector2(white_space * 2, white_space * 2)
	var slice = (OS.get_window_size() - spacing) / tile_count
	var size = 0
	if slice.x > slice.y:
		size = slice.y
	else:
		size = slice.x
	_tile_size = int(floor(size))


func _set_playfield():
	var size = _tile_size * tile_count
	get_parent().rect_min_size = Vector2(size, size)


func _set_game_paused(value: bool):
	set_process(not value)
	_game_paused = value


func _set_snake():
	_snake.clear()
	var center = int(float(tile_count) / 2.0)
	_snake.push_back(Vector2(center, center))
	_direction = null


func _set_apple():
	var x = randi() % tile_count
	var y = randi() % tile_count
	_apple_pos = Vector2(float(x), float(y))


func _turn_snake():
	if _input_stack.empty():
		return
	var dir = _input_stack.pop_front()
	match dir:
		Direction.UP:
			if _direction == Direction.DOWN:
				return
		Direction.DOWN:
			if _direction == Direction.UP:
				return
		Direction.LEFT:
			if _direction == Direction.RIGHT:
				return
		Direction.RIGHT:
			if _direction == Direction.LEFT:
				return
	_direction = dir


func _move_snake() -> Vector2:
	var snake_head = _snake.back()
	var new_head_pos = snake_head
	if _direction == Direction.UP:
		new_head_pos.y -= 1
	elif _direction == Direction.DOWN:
		new_head_pos.y += 1
	elif _direction == Direction.LEFT:
		new_head_pos.x -= 1
	elif _direction == Direction.RIGHT:
		new_head_pos.x += 1
	return new_head_pos


func _check_for_collision(new_head_pos: Vector2) -> bool:
	for snake_part in _snake:
		if new_head_pos.is_equal_approx(snake_part):
			return true
	if new_head_pos.x < 0:
		return true
	if new_head_pos.x >= tile_count:
		return true
	if new_head_pos.y < 0:
		return true
	if new_head_pos.y >= tile_count:
		return true
	return false


func _game_over():
	_set_game_paused(true)
	_set_snake()
	if _score > _high_score:
		_high_score = _score
	_main.display_score(_score)
	_main.display_highscore(_high_score)
	var message = TranslationServer.translate("T_SNAKE_END_MESSAGE")
	GameManager.end_game(message % _score, _score)
	_score = 0


func _check_for_apple(new_head_pos: Vector2):
	_snake.push_back(new_head_pos)
	if new_head_pos.is_equal_approx(_apple_pos):
		_set_apple()
		_score += 1
		_main.display_score(_score)
	else:
		_snake.remove(0)


func _draw_snake():
	var snake_size = _snake.size()
	for i in snake_size:
		var snake_part = _snake[i]
		var weight = 1.0
		if snake_size > 1:
			weight = float(i) / (float(snake_size - 1))
		_draw_colored_snake_part(snake_part, weight)


func _draw_colored_snake_part(snake_part, weight):
	var color: Color
	if color_scheme == ColorScheme.CLASSIC:
		color = COLORS.SNAKE_COLOR
	elif color_scheme == ColorScheme.FIREFLY:
		color = COLORS.FIREFLY_END.linear_interpolate(COLORS.FIREFLY_START, weight)
	elif color_scheme == ColorScheme.MATCHSTICK:
		if weight == 1:
			color = COLORS.MATCHSTICK_HEAD
		else:
			color = COLORS.MATCHSTICK_STICK
	elif color_scheme == ColorScheme.RAINBOW:
		var color1
		var color2
		var sub_weight
		if weight > 0.75:
			color1 = COLORS.RED
			color2 = COLORS.YELLOW
			sub_weight = (weight - 0.75) * 4
		elif weight > 0.5:
			color1 = COLORS.YELLOW
			color2 = COLORS.GREEN
			sub_weight = (weight - 0.5) * 4
		elif weight > 0.375:
			color1 = COLORS.GREEN
			color2 = COLORS.CYAN
			sub_weight = (weight - 0.375) * 8
		elif weight > 0.25:
			color1 = COLORS.CYAN
			color2 = COLORS.BLUE
			sub_weight = (weight - 0.25) * 8
		else:
			color1 = COLORS.BLUE
			color2 = COLORS.PURPLE
			sub_weight = weight * 4
		color = color2.linear_interpolate(color1, sub_weight)
	_draw_square(snake_part, color)


func _draw_apple():
	_draw_square(_apple_pos, COLORS.APPLE_COLOR)


func _draw_square(pos: Vector2, color: Color):
	var rect = Rect2(pos * _tile_size, Vector2(_tile_size, _tile_size))
	draw_rect(rect, color)
