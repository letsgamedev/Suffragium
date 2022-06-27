extends CanvasLayer

signal pause_menu_opened
signal pause_menu_closed

onready var _main := $Control


func _ready():
	_main.hide()


func _input(event: InputEvent):
	if !event is InputEventKey:
		return
	if !event.is_action_pressed("ui_cancel"):
		return
	if event.is_echo():
		return

	if _is_open():
		_unpause()
	else:
		_pause()
	get_tree().set_input_as_handled()


func _pause():
	_main.show()
	GameManager.pause_game()
	emit_signal("pause_menu_opened")
	get_tree().paused = true


func _unpause():
	_main.hide()
	emit_signal("pause_menu_closed")
	get_tree().paused = false
	GameManager.unpause_game()


func _is_open() -> bool:
	return _main.visible


func _on_ButtonResume_pressed():
	_unpause()


func _on_ButtonRestart_pressed():
	_unpause()
	GameManager.restart_game()
	queue_free()


func _on_ButtonMenu_pressed():
	_unpause()
	GameManager.end_game()
	queue_free()
