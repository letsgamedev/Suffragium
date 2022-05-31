extends Node
signal action_just_pressed(action_name, value, device_id)
signal action_just_released(action_name, value, device_id)

const ACTION_MAPPING_PATH: String = "res://games/shared_screen_mp/input_manager/action_mapping.gd"
onready var action_mapping = preload(ACTION_MAPPING_PATH).new()


func _input(event):
	if event is InputEventMouseMotion:
		return
	if event is InputEventJoypadMotion:
		return

	if event is InputEventKey:
		var action: String = action_mapping.find_key_action(event.physical_scancode)
		if action.length() > 0:
			if event.pressed:
				emit_signal("action_just_pressed", action, float(event.pressed), -1)
			else:
				emit_signal("action_just_released", action, float(event.pressed), -1)
			return

	if event is InputEventJoypadButton:
		var action: String = action_mapping.find_button_action(event.button_index)
		if action.length() > 0:
			if event.pressed:
				emit_signal("action_just_pressed", action, float(event.pressed), event.device)
			else:
				emit_signal("action_just_released", action, float(event.pressed), event.device)
			return
