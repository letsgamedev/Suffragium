extends VBoxContainer

var custom_name := false

@onready var _button_group: ButtonGroup = $CheckBox.group
@onready var _line_edit := $LineEdit
@onready var _color_picker := $ColorPickerButton
@onready var _first_button := $CheckBox


func _ready():
# warning-ignore:return_value_discarded
	_button_group.connect("pressed", Callable(self, "_on_selection_change"))
	_on_selection_change(_button_group.get_pressed_button())
	#setup color picker
	var pick: ColorPicker = _color_picker.get_picker()
	pick.presets_visible = false


func get_option():
	return _button_group.get_pressed_button().get_index() - _first_button.get_index()


func get_name():
	return _line_edit.text


func _get_auto_name() -> String:
	return tr(_button_group.get_pressed_button().text)


func get_player_color():
	return _color_picker.color


func _on_LineEdit_text_changed(_new_text):
	custom_name = true


func _on_selection_change(button: CheckBox):
	if !custom_name:
		_line_edit.text = tr(button.text)
		call_deferred("check_name")


# this is futureproofed for many more than 2 players
func check_name():
	# don't check if the name is custom
	if !custom_name:
		var prev_names := []
		# get all names of the previus player configurators
		for i in range(get_index()):
			prev_names.push_back(get_parent().get_child(i).get_name())

		# find a possible name
		var pos_name: String = _get_auto_name()
		var j = 1
		while prev_names.has(pos_name):
			j += 1
			pos_name = str(get_name(), j)

		# save the new name
		_line_edit.text = pos_name

	# tell the next player configurator to check the name
	if get_parent().get_child_count() > get_index() + 1:
		get_parent().get_child(get_index() + 1).check_name()
