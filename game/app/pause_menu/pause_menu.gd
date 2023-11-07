extends CanvasLayer

signal pause_menu_opened
signal pause_menu_closed
signal custom_button_pressed(text)

var _custom_btns := {}
var _custom_pages := {}

@onready var _main := $Control
@onready var _btn_list: VBoxContainer = $Control/CC/VC/CustomBtns


func _ready():
	_main.hide()


func _input(event: InputEvent):
	if !event is InputEventKey:
		return
	if !event.is_action_pressed("ui_cancel"):
		return
	if event.is_echo():
		return
	if GameManager.is_in_main_menu():
		return

	if is_open():
		# only unpause if no pages were open
		if !_close_custom_pages():
			unpause()
	else:
		pause()
	get_viewport().set_input_as_handled()


func add_custom_button(text: String, idx := -1) -> Button:
	if _custom_btns.has(text):
		return null  # skip if already exists
	var btn := Button.new()
	btn.text = text
	Utils.handle_error(btn.connect("pressed", Callable(self, "_on_custom_btn_pressed").bind(text)))
	_custom_btns[text] = btn
	if idx < 0 or _btn_list.get_child_count() == 0:
		_btn_list.add_child(btn)
	else:
		var this_is_a_node: Node = _btn_list.get_child(
			int(min(idx, _btn_list.get_child_count() - 1))
		)
		this_is_a_node.add_sibling(btn)
	_btn_list.show()
	return btn


func add_custom_page(page: Control, page_name: String):
	if _custom_pages.has(page_name):
		return  # skip if page already exists
	var btn := add_custom_button(page_name)
	if !btn is Button:
		return  # skip if button creation failed
	Utils.handle_error(btn.connect("pressed", Callable(page, "show")))
	page.hide()
	_custom_pages[page_name] = page
	add_child(page)


func clear_custom_content():
	for btn in _custom_btns.values():
		btn.queue_free()
	_custom_btns.clear()
	_btn_list.hide()
	for page in _custom_pages.values():
		page.queue_free()
	_custom_pages.clear()


func remove_custom_page(page_name: String):
	if !_custom_pages.has(page_name):
		return
	_custom_pages[page_name].queue_free()
	if _custom_pages.erase(page_name):
		pass


func remove_custom_button(text: String):
	if !_custom_btns.has(text):
		return
	_custom_btns[text].queue_free()
	if _custom_btns.erase(text):
		pass
	if _custom_btns.size() == 0:
		_btn_list.hide()


func pause():
	_main.show()
	GameManager.pause_game()
	emit_signal("pause_menu_opened")
	get_tree().paused = true


func unpause():
	_main.hide()
	emit_signal("pause_menu_closed")
	get_tree().paused = false
	GameManager.unpause_game()


func is_open() -> bool:
	return _main.visible


func get_custom_pages() -> Dictionary:
	return _custom_pages.duplicate()


func get_custom_buttons() -> Dictionary:
	return _custom_btns.duplicate()


func _on_ButtonResume_pressed():
	unpause()


func _on_ButtonRestart_pressed():
	unpause()
	GameManager.restart_game()


func _on_ButtonMenu_pressed():
	unpause()
	GameManager.end_game(null, null, false)


func _on_custom_btn_pressed(text):
	emit_signal("custom_button_pressed", text)


# closes all custom pages and returns false if none were open
func _close_custom_pages() -> bool:
	var was_open := false
	for page in _custom_pages:
		if _custom_pages[page].visible:
			was_open = true
			_custom_pages[page].hide()

	return was_open
