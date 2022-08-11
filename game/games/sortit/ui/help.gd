extends MarginContainer

var close_menu := false
onready var _pc := $PC

func _ready():
	set_process_input(false)

func _on_ExitBtn_pressed():
	hide()

func _input(event):
	if event is InputEventMouseButton:
		if !_pc.get_rect().has_point(event.position):
			hide()
			get_tree().set_input_as_handled()


func _on_Help_visibility_changed():
	set_process_input(visible)
	if visible:
		return
	if close_menu:
		close_menu = false
		PauseMenu.unpause()


