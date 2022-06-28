extends Control

onready var _splash_logo: Control = $SplashLogo

onready var _tween_scene_fade_out: Tween = $TweenSceneFadeOut
onready var _background: ColorRect = $Background
onready var _overlay: ColorRect = $Overlay

onready var _timer_wait_250: Timer = _splash_logo.get_node("Wait250")
onready var _timer_wait_500: Timer = _splash_logo.get_node("Wait500")
onready var _timer_wait_1000: Timer = _splash_logo.get_node("Wait1000")

onready var _tween_fade_in: Tween = _splash_logo.get_node("TweenFadeIn")
onready var _tween_part_1: Tween = _splash_logo.get_node("TweenPart1")
onready var _tween_part_2: Tween = _splash_logo.get_node("TweenPart2")
onready var _tween_fade_out: Tween = _splash_logo.get_node("TweenFadeOut")

onready var _audio_player: AudioStreamPlayer = _splash_logo.get_node("AudioStreamPlayer")

onready var _part_1: TextureRect = _splash_logo.get_node("Part1")
onready var _part_2: TextureRect = _splash_logo.get_node("Part2")


func _ready():
	var logo_scale = OS.get_window_size().x / 1228.0 * 0.64
	_splash_logo.rect_scale = Vector2(logo_scale, logo_scale)
	_setup_tween_fade_in()
	_setup_tween_part_1()
	_setup_tween_part_2()
	_setup_tween_fade_out()
	_setup_tween_scene_fade_out()
	_timer_wait_250.start()


func _setup_tween_fade_in():
	Utils.handle_tween_fail(_tween_fade_in.interpolate_property(
		_overlay,
		"color",
		Color(0, 0, 0, 1),
		Color(0, 0, 0, 0),
		0.25,
		Tween.TRANS_QUAD,
		Tween.EASE_IN
	))


func _setup_tween_part_1():
	Utils.handle_tween_fail(_tween_part_1.interpolate_property(
		_part_1, "rect_position:x", -347, -849, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	))


func _setup_tween_part_2():
	Utils.handle_tween_fail(_tween_part_2.interpolate_property(
		_part_2, "rect_position:x", -347, 238, 0.5, Tween.TRANS_QUAD, Tween.EASE_IN_OUT
	))


func _setup_tween_fade_out():
	Utils.handle_tween_fail(_tween_fade_out.interpolate_property(
		_overlay,
		"color",
		Color(0, 0, 0, 0),
		Color(0, 0, 0, 1),
		0.16,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	))


func _setup_tween_scene_fade_out():
	Utils.handle_tween_fail(_tween_scene_fade_out.interpolate_property(
		_overlay,
		"color",
		Color(0, 0, 0, 1),
		Color(0, 0, 0, 0),
		0.5,
		Tween.TRANS_QUAD,
		Tween.EASE_OUT
	))


func _on_Wait250_timeout():
	Utils.handle_tween_fail(_tween_fade_in.start())


func _on_TweenFadeIn_tween_completed(_object, _key):
	_timer_wait_500.start()


func _on_Wait500_timeout():
	_audio_player.play()
	Utils.handle_tween_fail(_tween_part_1.start())
	Utils.handle_tween_fail(_tween_part_2.start())


func _on_TweenPart2_tween_completed(_object, _key):
	_timer_wait_1000.start()


func _on_Wait1000_timeout():
	Utils.handle_tween_fail(_tween_fade_out.start())


func _on_TweenFadeOut_tween_completed(_object, _key):
	_background.visible = false
	_splash_logo.visible = false
	Utils.handle_tween_fail(_tween_scene_fade_out.start())


func _on_TweenSceneFadeOut_tween_completed(_object, _key):
	queue_free()
