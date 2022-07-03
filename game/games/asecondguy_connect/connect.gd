extends Node2D

signal chip_spawned(chip)

const END_MESSAGE := "%s won"
const CHIP_SCRIPT := preload("res://games/asecondguy_connect/chip.gd")

var player_names := []
var player_colors := []
var fallen_chips := []

var _last_chip: CHIP_SCRIPT
var _end_condition := 0
var _chips_played := 0
var _win_chip_pos := []

onready var _play_area := $PlayArea
onready var _grid := $Grid
onready var _chips := $Chips
onready var _spawners := [$Spawner1, $Spawner2]
onready var _info_label := $UI/PanelContainer/InfoLabel


func _ready():
	randomize()
	# setup the code representation of all played chips
	for _x in range(_grid.grid_size.x):
		var tmp := []
		for _y in range(_grid.grid_size.y):
			tmp.push_back(null)
		fallen_chips.push_back(tmp)


func start():
	_spawn_chip()


func _empty():
	$Bounds/Bottom.set_deferred("disabled", true)
	for c in _chips.get_children():
		# set all chips back to rigid mode
		c.set_deferred("mode", 0)
	if !_win_chip_pos.empty():
		var line: Line2D = preload("res://games/asecondguy_connect/win_line.tscn").instance()
		line.grid_points = _win_chip_pos
		line.default_color = player_colors[_last_chip.player_id]
		_grid.add_child(line)
	if _end_condition == 0:
		_info_label.start("Draw")
	else:
		_info_label.start(END_MESSAGE % player_names[_end_condition - 1])


func _on_PlayArea_body_exited(_body):
	if _end_condition == -1:
		return
	if _play_area.get_overlapping_bodies().size() == 0:
		if _end_condition == 0:
			GameManager.end_game("Draw")
		else:
			GameManager.end_game(END_MESSAGE % player_names[_end_condition - 1])


func _on_chip_sleep(chip: RigidBody2D):
	if !chip.sleeping:
		return
	_last_chip = chip
	var grid_pos: Vector2 = _grid.global_to_grid_pos(chip.position)
	if _grid.is_in_grid(grid_pos):
		chip.set_deferred("mode", chip.MODE_STATIC)
		_chips_played += 1
		fallen_chips[grid_pos.x][grid_pos.y] = chip.player_id
		_check_game_end_from_chip(grid_pos, chip.player_id)
		# max number of chips is 42
		if _chips_played == 42 or _end_condition != 0:
			_empty()
		else:
			# [1, 0][last_id] ==> 0 -> 1, 1 -> 0
			_spawn_chip([1, 0][chip.player_id])


func _spawn_chip(player_id := 0):
	var chip: RigidBody2D = preload("res://games/asecondguy_connect/chip.tscn").instance()
	chip.player_id = player_id
	chip.color = player_colors[player_id]
	chip.global_position = (
		_spawners[player_id].global_position
		+ Vector2(rand_range(-10, 10), rand_range(-10, 10))
	)
	if chip.connect("sleeping_state_changed", self, "_on_chip_sleep", [chip]) != OK:
		GameManager.end_game("A fatal error occured.")
	_chips.call_deferred("add_child", chip)
	_info_label.start(player_names[player_id] + "'s turn")
	emit_signal("chip_spawned", chip)


# checks the chip and updates _end_condition
func _check_game_end_from_chip(at: Vector2, player_id):
	# check all 4 valid axis
	for axis in [Vector2(1, 0), Vector2(0, 1), Vector2(1, 1), Vector2(-1, 1)]:
		# check both directions of the axis and add them together
		var dir1: int = mesure_chip_run(at, axis, player_id)
		var dir2: int = mesure_chip_run(at, axis * -1, player_id)
		var count := 1 + dir1 + dir2
		# if the row is at least 4 long the end condition changes
		if count >= 4:
			_end_condition = player_id + 1
			_win_chip_pos.push_back(at)
			for i in range(dir1):
				_win_chip_pos.push_back(at + axis * (i + 1))
			_win_chip_pos.invert()
			for i in range(dir2):
				_win_chip_pos.push_back(at - axis * (i + 1))
			return


# assumes origin is a valid chip and has the belongs to the player of player_id
# this doesn't count the first chip
# it goes only in one direction (dir) untill it leaves the grid
func mesure_chip_run(origin: Vector2, dir: Vector2, player_id: int) -> int:
	var pos := origin + dir
	# next position is outside the grid -> run ends
	if !_grid.is_in_grid(pos):
		return 0
	var chip = fallen_chips[pos.x][pos.y]
	# the next chip belongs to another player -> run ends
	if chip != player_id:
		return 0
	# the next chip belongs to this run
	# so the total run lenght is the run lengh from the next chip +1 (this chip)
	return mesure_chip_run(pos, dir, player_id) + 1


func _on_PlayArea_tree_exiting():
	_end_condition = -1
