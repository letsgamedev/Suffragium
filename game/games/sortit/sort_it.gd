class_name SortItRoot
extends MarginContainer

enum InputType { WASD_KEYS, IJKL_KEYS, NUMPAD_KEYS, ARROW_KEYS, JOY }

var game_scene = load("res://games/sortit/game.tscn")
var input_map = {
	InputType.WASD_KEYS:
	{
		"actions":
		{
			"left": KEY_A,
			"right": KEY_D,
			"up": KEY_W,
			"down": KEY_S,
			"left_magnet": KEY_Q,
			"right_magnet": KEY_E
		},
		"name": "WASD",
		"control_detail": "Left Magnet: Q\nRight Magnet: E"
	},
	InputType.IJKL_KEYS:
	{
		"actions":
		{
			"left": KEY_J,
			"right": KEY_L,
			"up": KEY_I,
			"down": KEY_K,
			"left_magnet": KEY_U,
			"right_magnet": KEY_O,
		},
		"name": "IJKL",
		"control_detail": "Left Magnet: U\nRight Magnet: O"
	},
	InputType.NUMPAD_KEYS:
	{
		"actions":
		{
			"left": KEY_KP_4,
			"right": KEY_KP_6,
			"up": KEY_KP_8,
			"down": KEY_KP_5,
			"left_magnet": KEY_KP_7,
			"right_magnet": KEY_KP_9,
		},
		"name": "Numpad",
		"control_detail": "Left Magnet: Numpad 7\nRight Magnet: Numpad 9"
	},
	InputType.ARROW_KEYS:
	{
		"actions":
		{
			"left": KEY_LEFT,
			"right": KEY_RIGHT,
			"up": KEY_UP,
			"down": KEY_DOWN,
			"left_magnet": KEY_DELETE,
			"right_magnet": KEY_PAGEDOWN,
		},
		"name": "Arrow keys",
		"control_detail": "Left Magnet: Delete\nRight Magnet: Page Down"
	},
#	InputType.JOY:
#	{
#		"actions":
#		{
#			"left": JOY_AXIS_0,
#			"right": JOY_AXIS_0,
#			"up": JOY_AXIS_1,
#			"down": JOY_AXIS_1,
#			"left_magnet": JOY_L,
#			"right_magnet": JOY_R,
#		},
#		"name": "Controller",
#		"control_detail":
#		"""Joystick to move
#		Left Magnet: Left Shoulder Button
#		Right Magnet: Right Shoulder Button"""
#	}
}


func _on_player_selector_start_game(player_inputs: Array):
	$PlayerSelector.hide()
	var game = game_scene.instantiate()
	var players_node = game.get_node("Players")
	players_node.player_inputs = player_inputs
	players_node.player_count = len(player_inputs)
	add_child(game)
