extends Control
# warning-ignore-all:return_value_discarded

onready var _splash_logo: Control = $SplashLogo

onready var _background: ColorRect = $Background
onready var _overlay: ColorRect = $Overlay

onready var _tween: Tween = _splash_logo.get_node("Tween")

onready var _audio_player: AudioStreamPlayer = _splash_logo.get_node("AudioStreamPlayer")

onready var _part_1: TextureRect = _splash_logo.get_node("Part1")
onready var _part_2: TextureRect = _splash_logo.get_node("Part2")


func _ready():
	var logo_scale = OS.get_window_size().x / 1228.0 * 0.64
	_splash_logo.rect_scale = Vector2(logo_scale, logo_scale)

	yield(get_tree().create_timer(0.25), "timeout")
	# Step 1 - Show "S" logo
	_tween.interpolate_property(
		_overlay,
		"color",
		Color(0, 0, 0, 1),
		Color(0, 0, 0, 0),
		0.25,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	)
	_tween.start()
	yield(_tween, "tween_completed")
	# Step 2 - Move "S" logo to the left, show "Suffragium" test and play sound
	_tween.interpolate_property(
		_part_1, "rect_position:x", -347, -849, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	_tween.interpolate_property(
		_part_2, "rect_position:x", -347, 238, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	)
	_audio_player.play()
	_tween.start()
	yield(_tween, "tween_completed")
	# Step 3 - Wait 1 sec
	yield(get_tree().create_timer(1.0), "timeout")
	# Step 4 - Fadeout logo and text
	_tween.interpolate_property(
		_overlay,
		"color",
		Color(0, 0, 0, 0),
		Color(0, 0, 0, 1),
		0.16,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	_tween.start()
	yield(_tween, "tween_completed")
	# Step 4 - Fadeout Scene
	_background.visible = false
	_splash_logo.visible = false
	_tween.interpolate_property(
		_overlay,
		"color",
		Color(0, 0, 0, 1),
		Color(0, 0, 0, 0),
		0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	)
	_tween.start()
	yield(_tween, "tween_completed")
	# Step 5 - Remove Scene
	queue_free()
