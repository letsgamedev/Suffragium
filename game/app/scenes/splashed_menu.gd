extends Node

onready var tween = $Control/Tween


func _ready():
	tween.interpolate_property(
		$Control/ColorRect,
		"color",
		Color(0, 0, 0, 1),
		Color(0, 0, 0, 0),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)


func _on_VideoPlayer_finished():
	$Control/ColorRect.visible = true
	$Control/AspectRatioContainer/VideoPlayer.visible = false
	tween.start()


func _on_Tween_tween_completed(_object, _key):
	$Control.queue_free()
