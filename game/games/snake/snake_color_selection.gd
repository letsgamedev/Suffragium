extends Control

var _main


func set_main(main):
	_main = main


func _select_color_scheme(color_scheme: int):
	_main.set_color_scheme(color_scheme)
	queue_free()


func _on_ButtonClassic_pressed():
	_select_color_scheme(0)


func _on_ButtonFirefly_pressed():
	_select_color_scheme(1)


func _on_ButtonMatchstick_pressed():
	_select_color_scheme(2)


func _on_ButtonRainbow_pressed():
	_select_color_scheme(3)
