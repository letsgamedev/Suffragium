# warning-ignore-all:return_value_discarded
extends MarginContainer

var balloon_scene := preload("res://games/testgame/balloon.tscn")

var colors := {
	"Red": Color.red,
	"Green" : Color.green,
	"Yellow" : Color.yellow,
	"Blue": Color.blue,
	"Purple": Color.purple,
	"Orange": Color.orange,
}


onready var _timer := $Timer
onready var _label := $VBoxContainer/Label
onready var _area := $VBoxContainer/balloonArea
onready var _rng := RandomNumberGenerator.new()
onready var _particles := $VBoxContainer/Particles2D

var search_color : Color


func _ready():
	_rng.randomize()
	start()

func start():
	var i = _rng.randi_range(0, colors.size()-1)
	_label.text = "Pop the %s balloon" % colors.keys()[i]
	search_color = colors.values()[i]
	call_deferred("_spawn")

func _process(_delta):
	var offset := sin(_timer.time_left * 2 * PI)
	for balloon in _area.get_children():
		balloon.rect_position.y += offset


func _spawn():
	var possible := colors.values()
	possible.erase(search_color)
	
	for _i in range(_rng.randi_range(1, 3)):
		_spawn_color(search_color)
	
	for _i in range(_rng.randi_range(3, 7)):
		_spawn_color(possible[_rng.randi_range(0, possible.size()-1)])
	

func _spawn_color(color:Color):
	var b : TextureButton = balloon_scene.instance()
	_area.add_child(b)
	# position
	var max_pos : Vector2 = _area.rect_size-b.rect_size*b.rect_scale
	b.rect_position.x = _rng.randf_range(0, max_pos.x)
	b.rect_position.y = _rng.randf_range(0, max_pos.y)
	
	# signals
	b.connect("pressed", self, "_on_destroy", [color, b])
	b.connect("pressed", b, "queue_free")
	# modulate
	b.self_modulate = color
	


func _on_destroy(color:Color, button=null):
	if color.is_equal_approx(search_color):
		_delete_all()
		if button is TextureButton:
			_particles.global_position = button.rect_global_position+button.rect_size/2*button.rect_scale
			_particles.restart()
		$respawnTimer.start()
	

func _delete_all():
	for b in _area.get_children():
		b.queue_free()



func _on_respawnTimer_timeout():
	_spawn()
