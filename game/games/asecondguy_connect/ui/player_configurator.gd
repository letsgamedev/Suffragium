extends VBoxContainer

var custom_name := false

onready var _button_group: ButtonGroup = $CheckBox.group
onready var _line_edit := $LineEdit
onready var _color_picker := $ColorPickerButton
onready var _first_button := $CheckBox


func _ready():
# warning-ignore:return_value_discarded
	_button_group.connect("pressed", self, "_on_selection_change")
	_on_selection_change(_button_group.get_pressed_button())
	#setup color picker
	var pick: ColorPicker = _color_picker.get_picker()
	pick.presets_visible = false


func get_option():
	return _button_group.get_pressed_button().get_index() - _first_button.get_index()


func get_name():
	return _line_edit.text


func get_player_color():
	return _color_picker.color


func _on_LineEdit_text_changed(_new_text):
	custom_name = true


func _on_selection_change(button: CheckBox):
	if !custom_name:
		_line_edit.text = button.text
