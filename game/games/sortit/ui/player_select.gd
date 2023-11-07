@tool
extends PanelContainer

signal got_input(input_type)

@export var get_input_style: StyleBoxFlat
@export var get_input: bool:
	get = get_get_input,
	set = set_get_input
@export var display: bool:
	get = get_display,
	set = set_display

var _control_scheme_name = ""
var _control_scheme_detail = ""
var _display = false
var _get_input = false

@onready var _player_text = $CenterContainer/VBoxContainer/PlayerText
@onready var _description_text = $CenterContainer/VBoxContainer/DescriptionText
@onready var _controll_detail_text = $CenterContainer/VBoxContainer/ControllText


func set_display(do_display: bool):
	if do_display:
		self.remove_theme_stylebox_override("panel")
		$CenterContainer.show()
	else:
		self.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		$CenterContainer.hide()
	_display = do_display


func get_display() -> bool:
	return _display


func set_get_input(do_get_input: bool):
	# This check is needed, because the onready vars might not be initialized when the node is created
	if not is_inside_tree():
		_get_input = do_get_input
		return

	if do_get_input:
		set_process_input(true)
		self.add_theme_stylebox_override("panel", get_input_style)
		_description_text.text = "Press button to add"
		_controll_detail_text.text = ""
	else:
		set_process_input(false)
		self.remove_theme_stylebox_override("panel")
		_description_text.text = _control_scheme_name
		_controll_detail_text.text = _control_scheme_detail
	_get_input = do_get_input


func get_get_input() -> bool:
	return _get_input


func _ready():
	if Engine.is_editor_hint():
		return
	_player_text.text = name
	# Update the state once all the onready nodes are initialized
	set_get_input(_get_input)
	set_display(_display)


func _input(event):
	var input_map = $"../../../../../..".input_map as Dictionary
	if event is InputEventKey:
		if not event.pressed:
			var keyboard_input_type = null
			# Try to find a control scheme, that contains the released button
			for input_type in input_map.keys():
				match typeof(input_type):
					SortItRoot.InputType.JOY:
						pass
					_:
						var actions = input_map[input_type]["actions"] as Dictionary
						for action_key in actions.values():
							if action_key == event.keycode:
								keyboard_input_type = input_type
			if keyboard_input_type == null:
				return
			_control_scheme_name = "Keyboard: " + input_map[keyboard_input_type]["name"]
			_control_scheme_detail = input_map[keyboard_input_type]["control_detail"]
			emit_signal("got_input", [keyboard_input_type, -1])
	if event is InputEventJoypadButton:
		if not event.pressed:
			_control_scheme_name = (
				input_map[SortItRoot.InputType.JOY]["name"] + " " + str(event.device)
			)
			_control_scheme_detail = input_map[SortItRoot.InputType.JOY]["control_detail"]
			emit_signal("got_input", [SortItRoot.InputType.JOY, event.device])
