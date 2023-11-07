extends Camera2D

var default_zoom: float = 0.4
var default_size: Vector2 = Vector2(1024, 600)


func _ready():
	# warning-ignore:return_value_discarded
	get_tree().get_root().connect("size_changed", Callable(self, "_on_resize"))
	_on_resize()


func _on_resize():
	var new_size: Vector2 = get_viewport_rect().size
	var factor: Vector2 = Vector2.ZERO
	factor.x = default_size.x / new_size.x
	factor.y = default_size.y / new_size.y
	if factor.x > factor.y:
		zoom = Vector2(default_zoom * factor.x, default_zoom * factor.x)
	else:
		zoom = Vector2(default_zoom * factor.y, default_zoom * factor.y)
