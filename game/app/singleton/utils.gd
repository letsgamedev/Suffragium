extends Node


func open_url(url: String):
	Utils.handle_error(OS.shell_open(url))


func change_scene_to_file(scene_path: String):
	return print_error(
		get_tree().change_scene_to_file(scene_path), "Could not change scene to '%s'", [scene_path]
	)


func handle_error(err: int, err_msg: String = "", formats: Array = []) -> void:
	assert(err == print_error(err, err_msg, formats))


func print_error(err: int, err_msg: String = "", formats: Array = []) -> int:
	if err == OK:
		return OK
	if err_msg == "":
		push_error("Error %s" % err)
		return err
	if formats:
		err_msg = err_msg % formats
	push_error("Error %s - %s" % [err, err_msg])
	return err


func handle_tween_fail(success: bool):
	if not success:
		push_error("Tween returned false")
