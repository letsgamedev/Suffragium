extends Node
signal action_just_pressed(action_name, value, device_id)
signal action_just_released(action_name, value, device_id)

enum Direction { UP, DOWN, LEFT, RIGHT }

const ACTION_MAPPING_PATH: String = "res://games/shared_screen_mp/input_manager/action_mapping.gd"

var disable_input: bool = false

var joypad_deadzone: float = 0.2
var joypad_stick_left_reseted: Array = [true, true, true, true]

onready var action_mapping = preload(ACTION_MAPPING_PATH).new()


# Disable input when window out of focus, for network debuging.
func _notification(what):
	match what:
		NOTIFICATION_WM_FOCUS_OUT:
			disable_input = true
		NOTIFICATION_WM_FOCUS_IN:
			disable_input = false


func _input(event):
	if disable_input:
		return
	if event is InputEventMouseMotion:
		return

	elif event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_1:
			_stick_axis_logic(
				event.axis, event.axis_value, Direction.LEFT, Direction.RIGHT, event.device
			)
		elif event.axis == JOY_AXIS_0:
			_stick_axis_logic(
				event.axis, event.axis_value, Direction.UP, Direction.DOWN, event.device
			)

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


func _stick_axis_logic(axis: int, axis_value: float, minus: int, plus: int, device_id: int):
	var actions: Array = action_mapping.find_axis_action(axis)
	if actions.size() > 0:
		# Minus
		if axis_value < -joypad_deadzone:
			joypad_stick_left_reseted[minus] = false
			emit_signal("action_just_pressed", actions[1], -axis_value, device_id)
		elif !joypad_stick_left_reseted[minus]:
			joypad_stick_left_reseted[minus] = true
			emit_signal("action_just_released", actions[1], 0.0, device_id)
		# Plus
		if axis_value > joypad_deadzone:
			joypad_stick_left_reseted[plus] = false
			emit_signal("action_just_pressed", actions[0], axis_value, device_id)
		elif !joypad_stick_left_reseted[plus]:
			joypad_stick_left_reseted[plus] = true
			emit_signal("action_just_released", actions[0], 0.0, device_id)
