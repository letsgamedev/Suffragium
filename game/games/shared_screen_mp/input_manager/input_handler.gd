extends Node

var assigned_device_id: int = -1
var move_up: float = 0.0
var move_down: float = 0.0
var move_left: float = 0.0
var move_right: float = 0.0
var move_direction: Vector2 = Vector2.ZERO setget , _get_move_direction
onready var main = get_tree().current_scene


func _get_move_direction():
	return Vector2(move_right - move_left, move_down - move_up)


func _ready():
	main.get_node("InputManager").connect("action_just_pressed", self, "_on_action_just_pressed")
	main.get_node("InputManager").connect("action_just_released", self, "_on_action_just_released")


func _on_action_just_pressed(action_name: String, value: float, device_id: int):
	if device_id != assigned_device_id:
		if not (assigned_device_id == -1 and !_is_device_id_assigned(device_id)):
			return
	match action_name:
		"menu":
			print("open menu")
		"join_leave":
			_join_leave(device_id)
		"move_up":
			move_up = value
		"move_down":
			move_down = value
		"move_left":
			move_left = value
		"move_right":
			move_right = value
		_:
			print("ERROR:input_handler:_on_action_just_pressed():unkonwn action = ", action_name)


func _on_action_just_released(action_name: String, value: float, device_id: int):
	if device_id != assigned_device_id:
		if not (assigned_device_id == -1 and !_is_device_id_assigned(device_id)):
			return
	match action_name:
		"menu":
			print("close menu")
		"join_leave":
			pass
		"move_up":
			move_up = value
		"move_down":
			move_down = value
		"move_left":
			move_left = value
		"move_right":
			move_right = value
		_:
			print("ERROR:input_handler:_on_action_just_released():unkonwn action = ", action_name)


func _is_device_id_assigned(device_id: int) -> bool:
	for player_pawn in main.player_pawns:
		if player_pawn.input_handler.assigned_device_id == device_id:
			return true
	return false


func _join_leave(device_id: int):
	if !_is_device_id_assigned(device_id):
		main.add_player(device_id)
	elif device_id == assigned_device_id:
		main.remove_player(get_parent())
