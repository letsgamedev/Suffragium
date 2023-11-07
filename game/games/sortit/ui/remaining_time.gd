extends Label

@export var root_game_path: NodePath
@export var color_gradient: Gradient
@onready var _end_timer = get_node(root_game_path).get_node("EndTimer")
@onready var _hbox_container = $"../../../"
@onready var _vbox_container = $"../../../.."


func _ready():
	var players = get_node(root_game_path).get_node("Players")
	set_timer_location(players.player_count)


# Set the location of the label, based on how many players there are
func set_timer_location(player_count: int):
	if player_count == 1:
		# Top Left
		_hbox_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	else:
		_hbox_container.alignment = BoxContainer.ALIGNMENT_CENTER

	if player_count > 2:
		# Top middel
		_vbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	else:
		# Center
		_vbox_container.alignment = BoxContainer.ALIGNMENT_BEGIN


func _process(_delta):
	var left_seconds = _end_timer.time_left
	var minutes = left_seconds / 60.0
	var seconds = fposmod(minutes, 1) * 60
	if minutes < 1:
		text = str(floor(seconds))
		add_theme_color_override("font_color", color_gradient.sample(1 - seconds / 60.0))
	else:
		text = "%02d:%02d" % [minutes, seconds]
