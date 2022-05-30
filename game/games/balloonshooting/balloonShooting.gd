# warning-ignore-all:return_value_discarded
extends MarginContainer

const END_MESSAGE := "You got %s points!"
const COLOR_MESSAGE := "Pop the %s or the golden balloon"
const STATUS_MESSAGE := "You'r in stage %s/10 and have %s points!"

const COLORS := {
	"red": Color.red,
	"green": Color.green,
	"yellow": Color.yellow,
	"blue": Color.blue,
	"purple": Color.purple,
	"orange": Color.orange,
}
const GOLD_COLOR := Color.goldenrod

var balloon_scene := preload("res://games/balloonshooting/balloon.tscn")

var points := 0
var search_color: Color
var stage := 0
var stage_with_gold := 0
var time := 0.0

var _noise := OpenSimplexNoise.new()

onready var _timer := $Timer
onready var _respawn_timer := $RespawnTimer
onready var _color_label := $VBoxContainer/HBoxContainer/ColorLabel
onready var _status_label := $VBoxContainer/HBoxContainer/StatusLabel
onready var _area := $VBoxContainer/balloonArea
onready var _rng := RandomNumberGenerator.new()
onready var _particles := $VBoxContainer/Particles2D


func _ready():
	_rng.randomize()
	stage_with_gold = _rng.randi_range(0, 9)

	_noise.seed = _rng.randi()
	#_noise.octaves = 4
	#_noise.period = 0.1
	#_noise.persistence = 0.8

	start()


func start():
	var i = _rng.randi_range(0, COLORS.size() - 1)
	_color_label.text = COLOR_MESSAGE % COLORS.keys()[i]
	search_color = COLORS.values()[i]
	call_deferred("_spawn")


# Animates all balloons
func _process(_delta):
	time += _delta
	print(time)
	for balloon in _area.get_children():
		var balloon_size = balloon.rect_size * balloon.rect_scale
		var window_size = _area.rect_size

		var speed = 25.0 + hash(balloon) % 5
		var move_angle = hash(balloon) + (1.0 + _noise.get_noise_2d(time, hash(balloon))) * PI
		balloon.rect_position += speed * _delta * Vector2(cos(move_angle), sin(move_angle))

		if balloon.rect_position.x < -balloon_size.x:
			balloon.rect_position.x = window_size.x
		elif balloon.rect_position.x > window_size.x:
			balloon.rect_position.x = -balloon_size.x

		if balloon.rect_position.y < -balloon_size.y:
			balloon.rect_position.y = window_size.y
		elif balloon.rect_position.y > window_size.y:
			balloon.rect_position.y = -balloon_size.y


# spawns all balloons per round
func _spawn():
	var possible := COLORS.values()
	possible.erase(search_color)

	if stage_with_gold == stage:
		_spawn_color(GOLD_COLOR)

	#spawn 3-7 balloons of any color exept the search color
	for _i in range(_rng.randi_range(10, 15)):
		_spawn_color(possible[_rng.randi_range(0, possible.size() - 1)])

	#spawn 1 balloon with the search color
	_spawn_color(search_color)

	stage += 1
	_update_status()


# spawns one balloon of the given color
func _spawn_color(color: Color):
	var b: TextureButton = balloon_scene.instance()
	_area.add_child(b)
	# position
	var max_pos: Vector2 = _area.rect_size - b.rect_size * b.rect_scale
	b.rect_position.x = _rng.randf_range(0, max_pos.x)
	b.rect_position.y = _rng.randf_range(0, max_pos.y)

	# signals
	b.connect("pressed", self, "_on_destroy", [color, b])
	b.connect("pressed", b, "queue_free")
	# modulate
	b.self_modulate = color


func _on_destroy(color: Color, button = null):
	var is_gold = color.is_equal_approx(GOLD_COLOR)
	var is_search = color.is_equal_approx(search_color)
	if is_gold or is_search:
		if button is TextureButton:
			_particles.global_position = (
				button.rect_global_position
				+ button.rect_size / 2 * button.rect_scale
			)
			_particles.restart()
		if is_search:
			points += 1
			_delete_all()
			_respawn_timer.start()
		else:
			points += 5
	else:
		points -= 1
	_update_status()


func _delete_all():
	for b in _area.get_children():
		b.queue_free()


# timer leaves a little time between stage end and the next stage start or game end
func _on_RespawnTimer_timeout():
	if stage >= 10:
		GameManager.end_game(END_MESSAGE % points)
		return
	_spawn()


func _update_status():
	_status_label.text = STATUS_MESSAGE % [stage, points]
