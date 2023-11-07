extends Control

@onready var _splash_logo: Control = $SplashLogo


func _ready() -> void:
	var logo_scale: float = get_window().get_size().x / 1228.0 * 0.64
	_splash_logo.scale = Vector2(logo_scale, logo_scale)
	$AnimationPlayer.play("logo_cross_sweep")


func _on_animation_finished(_anim_name: StringName) -> void:
	queue_free()
