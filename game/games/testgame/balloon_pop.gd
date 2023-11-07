extends MarginContainer

const END_MESSAGE := "You got %d points!"
const COLOR_MESSAGE := "Pop a %s balloon"
const STATUS_MESSAGE := "You're in stage %d/10 and have %s points! (Your highscore is: %d)"

var balloon_scene := preload("res://games/testgame/balloon.tscn")

var colors := {
	"Red": Color.RED,
	"Green": Color.GREEN,
	"Yellow": Color.YELLOW,
	"Blue": Color.BLUE,
	"Purple": Color.PURPLE,
	"Orange": Color.ORANGE,
}

var points := 0
var stage := 0
var search_color: Color

@onready var _timer := $Timer
@onready var _respawn_timer := $RespawnTimer
@onready var _color_label := $VBoxContainer/HBoxContainer/ColorLabel
@onready var _status_label := $VBoxContainer/HBoxContainer/StatusLabel
@onready var _area := $VBoxContainer/balloonArea
@onready var _rng := RandomNumberGenerator.new()
@onready var _particles := $VBoxContainer/GPUParticles2D


func _ready():
	_rng.randomize()
	### start --- Data saving demo ---
	# var data = GameManager.get_game_data()
	# print("Loaded: ", data["num"] if "num" in data else null)
	# data["num"] = _rng.randi()
	# print("Saved: ", data["num"])
	# GameManager.end_game("", -data["num"])  # end game here to quickly test saving
	#### end  --- Data saving demo ---
	start()


func start():
	var i = _rng.randi_range(0, colors.size() - 1)
	_color_label.text = COLOR_MESSAGE % colors.keys()[i]
	search_color = colors.values()[i]
	call_deferred("_spawn")


# Animates all balloons
func _process(_delta):
	var offset := sin(_timer.time_left * 2 * PI)
	for balloon in _area.get_children():
		balloon.position.y += offset


# spawns all balloons per round
func _spawn():
	var possible := colors.values()
	possible.erase(search_color)

	#spawn 1-3 balloons with the search color
	for _i in range(_rng.randi_range(1, 3)):
		_spawn_color(search_color)

	#spawn 3-7 balloons of any color exept the search color
	for _i in range(_rng.randi_range(3, 7)):
		_spawn_color(possible[_rng.randi_range(0, possible.size() - 1)])

	stage += 1
	_update_status()


# spawns one balloon of the given color
func _spawn_color(color: Color):
	var b: TextureButton = balloon_scene.instantiate()
	_area.add_child(b)
	# position
	var max_pos: Vector2 = _area.size - b.size * b.scale
	b.position.x = _rng.randf_range(0, max_pos.x)
	b.position.y = _rng.randf_range(0, max_pos.y)

	# signals
	Utils.handle_error(b.connect("pressed", Callable(self, "_on_destroy").bind(color, b)))
	Utils.handle_error(b.connect("pressed", Callable(b, "queue_free")))
	# modulate
	b.self_modulate = color


func _on_destroy(color: Color, button = null):
	if color.is_equal_approx(search_color):
		points += 1
		_delete_all()
		if button is TextureButton:
			_particles.global_position = (button.global_position + button.size / 2 * button.scale)
			_particles.restart()
		_respawn_timer.start()
	else:
		points -= 1
		if points < 0:
			points = 0
	_update_status()


func _delete_all():
	for b in _area.get_children():
		b.queue_free()


# timer leaves a little time between stage end and the next stage start or game end
func _on_RespawnTimer_timeout():
	if stage >= 10:
		GameManager.end_game(END_MESSAGE % points, points)
		return
	_spawn()


func _update_status():
	var highscore_dict = GameManager.get_highscore()
	var highscore = points
	if highscore_dict.has("score"):
		highscore = highscore_dict["score"]
	_status_label.text = STATUS_MESSAGE % [stage, points, max(points, highscore)]
