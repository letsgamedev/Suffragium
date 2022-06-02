extends Node

## Takes unhandled input events, converts them into custom actions and
## sends them off.

signal action_just_pressed(action_name, value, device_id)
signal action_just_released(action_name, value, device_id)

enum { UP, DOWN, LEFT, RIGHT }

var disable_input: bool = false
var joypad_deadzone: float = 0.2

var _joypad_stick_left_reseted: Array = [true, true, true, true]

onready var action_mapping = preload("res://games/shared_screen_mp/input_manager/action_mapping.gd").new()


# Disable input when window out of focus, for network debuging.
# Joypads continue to send inputs even when the window is out of focus.
func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_OUT:
			disable_input = true
		NOTIFICATION_WM_FOCUS_IN:
			disable_input = false


func _unhandled_input(event):
	if disable_input:
		return
	if event is InputEventMouseMotion:
		return

	elif event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_1:
			_stick_axis_logic(event.axis, event.axis_value, LEFT, RIGHT, event.device)
		elif event.axis == JOY_AXIS_0:
			_stick_axis_logic(event.axis, event.axis_value, UP, DOWN, event.device)

	elif event is InputEventKey:
		var action: String = action_mapping.find_key_action(event.physical_scancode)
		if action.length() > 0:
			if event.pressed:
				emit_signal("action_just_pressed", action, float(event.pressed), -1)
			else:
				emit_signal("action_just_released", action, float(event.pressed), -1)
			return

	elif event is InputEventJoypadButton:
		var action: String = action_mapping.find_button_action(event.button_index)
		if action.length() > 0:
			if event.pressed:
				emit_signal("action_just_pressed", action, float(event.pressed), event.device)
			else:
				emit_signal("action_just_released", action, float(event.pressed), event.device)
			return


# Converts axis_value from range(-1, 1) into two actions.
func _stick_axis_logic(axis: int, axis_value: float, minus: int, plus: int, device_id: int):
	var actions: Array = action_mapping.find_axis_action(axis)
	if actions.size() > 0:
		# Minus
		if axis_value < -joypad_deadzone:
			_joypad_stick_left_reseted[minus] = false
			emit_signal("action_just_pressed", actions[1], -axis_value, device_id)
		elif !_joypad_stick_left_reseted[minus]:
			_joypad_stick_left_reseted[minus] = true
			emit_signal("action_just_released", actions[1], 0.0, device_id)
		# Plus
		if axis_value > joypad_deadzone:
			_joypad_stick_left_reseted[plus] = false
			emit_signal("action_just_pressed", actions[0], axis_value, device_id)
		elif !_joypad_stick_left_reseted[plus]:
			_joypad_stick_left_reseted[plus] = true
			emit_signal("action_just_released", actions[0], 0.0, device_id)
