extends Label

var _time_left := 1.0
var _time := 1.0
var _full_text: String


func start(new_text: String, time := 1.0):
	_time_left = time
	_time = time
	_full_text = tr(new_text)
	set_process(true)


func _process(delta):
	_time_left -= delta
# this is wanted
# warning-ignore:narrowing_conversion
	text = _full_text.substr(0, round((_time - _time_left) * _full_text.length()))
	if _time_left <= 0:
		set_process(false)
