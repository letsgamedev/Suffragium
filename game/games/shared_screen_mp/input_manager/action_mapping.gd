extends Node


func find_key_action(physical_scancode: int):
	match physical_scancode:
		KEY_ESCAPE:
			return "menu"
		KEY_W:
			return "move_up"
		KEY_S:
			return "move_down"
		KEY_A:
			return "move_left"
		KEY_D:
			return "move_right"
		_:
			return ""


func find_button_action(button_index: int):
	match button_index:
		JOY_START:
			return "menu"
		JOY_SELECT:
			return "join_leave"
		JOY_DPAD_UP:
			return "move_up"
		JOY_DPAD_DOWN:
			return "move_down"
		JOY_DPAD_LEFT:
			return "move_left"
		JOY_DPAD_RIGHT:
			return "move_right"
		_:
			return ""


func find_axis_action(axis: int):
	match axis:
		JOY_AXIS_0:
			return ["move_right", "move_left"]
		JOY_AXIS_1:
			return ["move_down", "move_up"]
		_:
			return []
