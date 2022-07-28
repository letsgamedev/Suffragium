extends Node2D

var player = null
var score := 0
onready var camera = $Camera
onready var ui = $UI
onready var map_manager = $MapManager
# onready var score_label = $score_label


func _ready():
	# score_label.set_as_toplevel(true)
	increase_score(0)
	map_manager.find_maps()
# warning-ignore:return_value_discarded
	map_manager.load_next_map()


func increase_score(increment: int):
	score += increment
	# score_label.text = String(score)


func kill_player():
	increase_score(-1)
	spawn_player()


func spawn_player():
	var spawn = map_manager.current_map.get_node("Spawn")
	if not is_instance_valid(spawn):
		return
	if not player:
		var new_player = load("res://games/pixel_side_scroller/pawns/character/character.tscn").instance()
		player = new_player
		player.position = spawn.position
		camera.target = player
		add_child(new_player)
	else:
		player.position = spawn.position
	yield(get_tree(), "idle_frame")
	player.enable()


func goal_reached():
	increase_score(1)
	if not map_manager.load_next_map():
		GameManager.end_game("Best Game Ever. 5/7 Rating", score)
