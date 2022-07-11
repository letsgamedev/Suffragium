extends Node2D

var player = null
onready var camera = $Camera
onready var ui = $UI
onready var map_manager = $MapManager


func _ready():
	map_manager.find_maps()
# warning-ignore:return_value_discarded
	map_manager.load_next_map()


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
	if not map_manager.load_next_map():
		GameManager.end_game("Best Game Ever. 5/7 Rating")
