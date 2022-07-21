extends CanvasLayer

var _game_config = null

onready var _main := $Control
onready var _label := $Control/CC/VC/Label


func _ready():
	pass


func _input(event: InputEvent):
	if !event is InputEventKey:
		return

	if event.is_echo():
		return

	if event.is_action_pressed("ui_cancel"):
		get_tree().set_input_as_handled()
		_on_ButtonMenu_pressed()
	elif event.is_action_pressed("ui_accept"):
		_on_ButtonRestart_pressed()
		get_tree().set_input_as_handled()


func show(text, game_config):
	_game_config = game_config

	if text == null:
		text = "T_GAME_ENDED"

	_label.text = text

	get_tree().paused = true


func _close():
	get_tree().paused = false
	queue_free()


func _on_ButtonRestart_pressed():
	_close()
	GameManager.load_game(_game_config)


func _on_ButtonMenu_pressed():
	_close()
	Utils.change_scene(GameManager.MENU_PATH)
