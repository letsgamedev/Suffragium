extends VBoxContainer

const STATUS_TEXT = "%d points"

export(float) var arrow_corner_separation = 10
export(float) var arrow_screen_size_fraction = 0.3

var _display_pointing_arrow = false
var _last_viewport_height = 0

onready var _pointing_arrow: Sprite = $PoinitingArrow
onready var _screen_height: int = OS.get_screen_size().y


func display_score(score: int):
	$HBoxContainer/StatusLabel.text = STATUS_TEXT % score


func set_pedestal_direction_angle(angle: float):
	_pointing_arrow.rotation = angle


func set_display_pointing_arrow(display: bool):
	# Only do something if the display state changed
	if display == _display_pointing_arrow:
		return
	_display_pointing_arrow = display
	# Play Fade in / Fade out animation
	var animation_player = _pointing_arrow.get_node("Fader") as AnimationPlayer
	if display:
		animation_player.play("Fade")
	else:
		animation_player.play_backwards("Fade")


func _update_pointing_arrow_position():
	# Only recalculate arrow position/scale, if viewport size changed
	var viewport_height = get_viewport().size.y
	if viewport_height == _last_viewport_height:
		return
	# Calculate arrow scale/size based on window and screen size
	var viewport_fraction = viewport_height / _screen_height
	var arrow_scale = viewport_fraction * arrow_screen_size_fraction
	_pointing_arrow.scale = Vector2(arrow_scale, arrow_scale)
	var arrow_size = _pointing_arrow.texture.get_size() * arrow_scale
	# Place arrow in bottom left corner with separation
	_pointing_arrow.position = Vector2(
		arrow_corner_separation * viewport_fraction + arrow_size.x / 2.0,
		viewport_height - arrow_size.y / 2.0 - arrow_corner_separation * viewport_fraction
	)


func _process(_delta):
	_update_pointing_arrow_position()
