class_name SortItRoot
extends MarginContainer

enum InputType { WASD_KEYS, IJKL_KEYS, NUMPAD_KEYS, ARROW_KEYS, JOY }

var game_scene = load("res://games/sortit/Game.tscn")
var input_map = {
	InputType.WASD_KEYS:
	{
		"left": KEY_A,
		"right": KEY_D,
		"up": KEY_W,
		"down": KEY_S,
		"left_magnet": KEY_Q,
		"right_magnet": KEY_E,
	},
	InputType.IJKL_KEYS:
	{
		"left": KEY_J,
		"right": KEY_L,
		"up": KEY_I,
		"down": KEY_K,
		"left_magnet": KEY_U,
		"right_magnet": KEY_O,
	},
	InputType.NUMPAD_KEYS:
	{
		"left": KEY_KP_4,
		"right": KEY_KP_6,
		"up": KEY_KP_8,
		"down": KEY_KP_5,
		"left_magnet": KEY_KP_7,
		"right_magnet": KEY_KP_9,
	},
	InputType.ARROW_KEYS:
	{
		"left": KEY_LEFT,
		"right": KEY_RIGHT,
		"up": KEY_UP,
		"down": KEY_DOWN,
		"left_magnet": KEY_DELETE,
		"right_magnet": KEY_PAGEDOWN,
	},
	InputType.JOY:
	{
		"left": JOY_AXIS_0,
		"right": JOY_AXIS_0,
		"up": JOY_AXIS_1,
		"down": JOY_AXIS_1,
		"left_magnet": JOY_L,
		"right_magnet": JOY_R,
	}
}


func _on_player_selector_start_game(player_inputs: Array):
	$PlayerSelector.hide()
	var game = game_scene.instance()
	var players_node = game.get_node("Players")
	players_node.player_inputs = player_inputs
	players_node.player_count = len(player_inputs)
	add_child(game)
