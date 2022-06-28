extends Node


func open_url(url: String):
	Utils.handle_error(OS.shell_open(url))


func handle_error(err: int, err_msg: String = "", formats: Array = []) -> void:
	if err == OK:
		return
	if err_msg == "":
		push_error("Error %s" % err)
		return
	if formats:
		err_msg = err_msg % formats
	push_error("Error %s - %s" % [err, err_msg])


func handle_tween_fail(success: bool):
	if not success:
		push_error("Tween returned false")
