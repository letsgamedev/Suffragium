tool
extends Spatial

export(float) var spacing setget set_spacing, get_spacing

var pedestal_numbers = []
var correct_count = 0

var _spacing = 3.0
var _assigned_player: SortItPlayer


func set_spacing(new_spacing: float):
	var last_pos = Vector3(0, -1.054, 0)
	for pedestal in get_children():
		pedestal.transform.origin = last_pos
		last_pos += Vector3(new_spacing, 0, 0)
	_spacing = new_spacing


func get_spacing() -> float:
	return _spacing


func dissable():
	hide()
	for pedestal in get_children():
		propagate_call("set_process", [false])
		propagate_call("set_physics_process", [false])
		propagate_call("set_process_internal", [false])
		pedestal.set_collision_layer_bit(0, false)
		pedestal.set_collision_mask_bit(0, false)
		pedestal.set_collision_mask_bit(1, false)
		pedestal.set_collision_mask_bit(2, false)


func enable():
	show()
	for pedestal in get_children():
		propagate_call("set_process", [true])
		propagate_call("set_physics_process", [true])
		propagate_call("set_process_internal", [true])
		pedestal.set_collision_layer_bit(0, true)
		pedestal.set_collision_mask_bit(0, true)
		pedestal.set_collision_mask_bit(1, true)
		pedestal.set_collision_mask_bit(2, true)


func set_color(color: Color):
	for pedestal in get_children():
		pedestal.set_color(color)


func set_assigned_player(assigned_player: SortItPlayer):
	_assigned_player = assigned_player
	# Give each pedestal a reference to all players
	var players = get_node("../../Players").get_children()
	for pedestal in get_children():
		pedestal.set_players(players)


func _ready():
	if Engine.is_editor_hint():
		return
	for pedestal in get_children():
		(pedestal as SortItPedestal).connect("box_held", self, "_on_box_held")
		(pedestal as SortItPedestal).connect("box_dropped", self, "_on_box_dropped")
		pedestal_numbers.push_back(-1)


func _update_correctness():
	var pedestals = get_children()
	correct_count = 0
	for i in len(pedestal_numbers):
		# Check if last number is smaller then the current pedestal number
		var last_number = pedestal_numbers[max(i - 1, 0)]
		var number = pedestal_numbers[i]
		var is_correct = number >= last_number and last_number != -1
		if is_correct:
			correct_count += 1
		(pedestals[i] as SortItPedestal).set_correct(is_correct)
	_assigned_player.status_display.display_score(correct_count)


func _on_box_held(index: int, box_number: int):
	pedestal_numbers[index] = box_number
	_update_correctness()


func _on_box_dropped(index: int, _box_number: int):
	pedestal_numbers[index] = -1
	_update_correctness()
