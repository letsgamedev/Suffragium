extends Label

export(NodePath) var root_game_path
export(Gradient) var color_gradient
onready var _end_timer = get_node(root_game_path).get_node("EndTimer")
onready var _hbox_cotainer = $"../../../"
onready var _vbox_cotainer = $"../../../.."


func _ready():
	var players = get_node(root_game_path).get_node("Players")
	set_timer_location(players.player_count)


# Set the location of the label, based on how many players there are
func set_timer_location(player_count: int):
	if player_count == 1:
		# Top Left
		_hbox_cotainer.alignment = BoxContainer.ALIGN_BEGIN
	else:
		_hbox_cotainer.alignment = BoxContainer.ALIGN_CENTER

	if player_count > 2:
		# Top middel
		_vbox_cotainer.alignment = BoxContainer.ALIGN_CENTER
	else:
		# Center
		_vbox_cotainer.alignment = BoxContainer.ALIGN_BEGIN


func _process(_delta):
	var left_seconds = _end_timer.time_left
	var minutes = left_seconds / 60.0
	var seconds = fposmod(minutes, 1) * 60
	if minutes < 1:
		text = str(floor(seconds))
		add_color_override("font_color", color_gradient.interpolate(1 - seconds / 60.0))
	else:
		text = "%02d:%02d" % [minutes, seconds]
