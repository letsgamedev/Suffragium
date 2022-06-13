extends CanvasLayer

signal pause_menu_opened
signal pause_menu_closed

onready var _main := $Margin
onready var _resume_btn := $Margin/VBox/ResumeBtn
onready var _reset_btn := $Margin/VBox/RestartBtn
onready var _quit_game_btn := $Margin/VBox/QuitgameBtn
onready var _quit_desc_btn := $Margin/VBox/QuitToDesctopBtn


func _ready():
	hide()


func _input(event):
	if !event is InputEventKey:
		return
	if !event.is_action_pressed("ui_cancel"):
		return
	if event.is_echo():
		return

	if is_open():
		hide()
	else:
		show()
	get_tree().set_input_as_handled()


func show():
	_main.show()
	emit_signal("pause_menu_opened")
	get_tree().paused = true
	_update_menu()


func hide():
	_main.hide()
	emit_signal("pause_menu_closed")
	get_tree().paused = false


func is_open():
	return _main.visible


func _update_menu():
	var game: ConfigFile = GameManager.last_loaded_game
	# true if a game is loaded
	var in_game: bool = is_instance_valid(game)

	_reset_btn.visible = in_game
	_quit_game_btn.visible = in_game


func _on_restartbtn_pressed():
	GameManager.load_game(GameManager.last_loaded_game)
	hide()


func _on_quitgamebtn_pressed():
	GameManager.end_game("")
	hide()


func _on_quittodesctopbtn_pressed():
	GameManager.end_game("")
	get_tree().quit()
