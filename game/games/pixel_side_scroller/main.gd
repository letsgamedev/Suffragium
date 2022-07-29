extends Node2D

var player = null
var levels_finished := 0
var deaths := 0
var stars_collected := 0
var star_count := 0

onready var camera = $Camera
onready var ui = $UI
onready var map_manager = $MapManager
# onready var score_label = $score_label


func _ready():
	map_manager.find_maps()
# warning-ignore:return_value_discarded
	map_manager.load_next_map()


func kill_player():
	deaths += 1
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


func count_star():
	star_count += 1


func collected_star():
	stars_collected += 1


func goal_reached():
	levels_finished += 1
	if not map_manager.load_next_map():
		GameManager.end_game(
			(
				TranslationServer.translate("T_PIXEL_SIDE_SCROLLER_END_MESSAGE")
				% [levels_finished, deaths, stars_collected, star_count]
			),
			stars_collected + levels_finished * 2 - deaths
		)
