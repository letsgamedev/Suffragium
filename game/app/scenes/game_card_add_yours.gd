extends ColorRect

var _menu


func set_menu_node(menu):
	_menu = menu


func _on_Button_pressed():
	_menu.open_participation_tab()
