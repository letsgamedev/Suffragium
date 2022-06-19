extends Node

const PLAYER_SCENE = preload("res://games/sortit/player.tscn")
const MIN_JOY_STRENGTH = 0.05

export(Array, Color) var player_colors

var player_count = 2
var player_inputs = []

var _pressed = {}
var _just_pressed = {}

onready var input_map = $"../../".input_map as Dictionary
onready var _pedestals = $"../Pedestals"


func set_player_colors_on_ground_plane():
	var ground_material: ShaderMaterial = $"../Map/Mesh".mesh.surface_get_material(0)
	# Set the colors of the floor grid lines based on the player colors
	for i in range(len(player_colors)):
		var color: Color = player_colors[i]
		var is_color_used = player_count > i
		if not is_color_used:
			# Desaturate and lighten quadrants on map, that are not used by a player
			color = Color.from_hsv(color.h, color.s * 0.4, color.v * 1.2, color.a)
		else:
			# Slightly desaturate grid lines to avoid drawing to much attention away
			color = Color.from_hsv(color.h, color.s * 0.8, color.v, color.a)
		ground_material.set_shader_param("player_color_" + str(i), color)


func spawn_players():
	# First dissable all pedestals
	for pedestal in _pedestals.get_children():
		pedestal.dissable()
	for i in range(player_count):
		# Instance new player
		var player = PLAYER_SCENE.instance(PackedScene.GEN_EDIT_STATE_INSTANCE)
		add_child(player)
		# Set player position next to assigned pedestals
		var player_pedestals = _pedestals.get_child(i)
		var pedestal_position = player_pedestals.global_transform.origin
		player.global_transform.origin = (
			Vector3(pedestal_position.x, 1, pedestal_position.z)
			- Vector3(0, 0, -4)
		)
		# Set player index and color
		player.player_index = i
		var player_color = player_colors[i]
		player.set_color(player_color)
		# Setup pedestals for player
		player_pedestals.set_assigned_player(player)
		player_pedestals.set_color(player_color)
		# Only enable pedestals, that are assigned to a player
		player_pedestals.enable()
	set_player_colors_on_ground_plane()


# Returns the best player index and the highest score
func get_best_player() -> Array:
	var highest_score = 0
	var best_player = 0
	for i in range(player_count):
		var score = _pedestals.get_child(i).correct_count
		if score > highest_score:
			highest_score = score
			best_player = i
	return [best_player, highest_score]


func get_action_strength(action: String, player_index: int) -> float:
	var player_input = player_inputs[player_index]
	var input_type = player_input[0]
	var input_device = player_input[1]
	var player_mapping = input_map[input_type]["actions"]
	match input_type:
		SortItRoot.InputType.JOY:
			var button = player_mapping[action]
			var key = ["joypad", button, input_device]
			if not _pressed.has(key):
				return 0.0
			var value = _pressed[key]
			return 0.0 if abs(value) < MIN_JOY_STRENGTH else value
		_:
			var button = player_mapping[action]
			var key = ["keyboard", button, -1]
			var value = 0.0 if not _pressed.has(key) else _pressed[key]
			if ["left", "right", "up", "down"].has(action):
				# Get opposite action, if checking for a directional action
				var negative_action
				match action:
					"left":
						negative_action = "right"
					"up":
						negative_action = "down"
					"right":
						negative_action = "left"
					"down":
						negative_action = "up"
				# Get value of oppiste action
				var negative_button = player_mapping[negative_action]
				var negative_key = ["keyboard", negative_button, -1]
				var negative_value = (
					0.0
					if not _pressed.has(negative_key)
					else _pressed[negative_key]
				)
				# Subtract negative action from positive action, so
				# that getting the strength of "right" will return -1, if the "left" action is held
				return value - negative_value
			return value


func is_action_just_pressed(action: String, player_index: int) -> bool:
	var player_input = player_inputs[player_index]
	var input_type = player_input[0]
	var input_device = player_input[1]
	var input_key_or_button = input_map[input_type]["actions"][action]
	match input_type:
		SortItRoot.InputType.JOY:
			return _just_pressed.has(["joypad", input_key_or_button, input_device])
		_:
			return _just_pressed.has(["keyboard", input_key_or_button, -1])


func is_action_pressed(action: String, player_index: int) -> bool:
	var player_input = player_inputs[player_index]
	var input_type = player_input[0]
	var input_device = player_input[1]
	var input_key_or_button = input_map[input_type]["actions"][action]
	match input_type:
		SortItRoot.InputType.JOY:
			var key = ["joypad", input_key_or_button, input_device]
			return false if not _pressed.has(key) else abs(_pressed[key]) > MIN_JOY_STRENGTH
		_:
			var key = ["keyboard", input_key_or_button, -1]
			return false if not _pressed.has(key) else _pressed[key] > 0.0


func _input(event: InputEvent):
	_just_pressed.clear()
	if event is InputEventKey and not event.echo:
		var key = ["keyboard", event.scancode, -1]
		if event.pressed:
			_pressed[key] = 1.0
			_just_pressed[key] = true
		else:
			_pressed[key] = 0.0
	elif event is InputEventJoypadButton:
		var key = ["joypad", event.button_index, event.device]
		if event.pressed:
			_pressed[key] = 1.0
			_just_pressed[key] = true
		else:
			_pressed[key] = 0.0
	elif event is InputEventJoypadMotion:
		var key = ["joypad", event.axis, event.device]
		_pressed[key] = event.axis_value
	elif event is InputEventMouseButton:
		var key = ["mouse", event.button_index, -1]
		if event.pressed:
			_pressed[key] = 1.0
			_just_pressed[key] = true
		else:
			_pressed[key] = 0.0
