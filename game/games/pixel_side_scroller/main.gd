extends Node2D

var player = null
var levels_finished := 0
var deaths := 0
var stars_collected := 0
var star_count := 0

@onready var camera = $Camera3D
@onready var ui = $UI
@onready var map_manager = $MapManager
# onready var score_label = $score_label


func _ready():
	map_manager.find_maps()
	display_stats()
# warning-ignore:return_value_discarded
	map_manager.load_next_map()


func kill_player() -> void:
	deaths += 1
	if player:
		player.on_kill()
	display_stats()
	spawn_player()


func spawn_player() -> void:
	var spawn = map_manager.current_map.get_node("Spawn")
	if not is_instance_valid(spawn):
		return
	if not player:
		var new_player = load("res://games/pixel_side_scroller/pawns/character/character.tscn").instantiate()
		player = new_player
		player.position = spawn.position
		camera.target = player
		add_child(new_player)
	else:
		player.position = spawn.position
	await get_tree().idle_frame
	player.enable()


func count_star() -> void:
	star_count += 1
	display_stats()


func collected_star() -> void:
	stars_collected += 1
	display_stats()


func display_stats() -> void:
	ui.stats_label.text = str(
		(
			TranslationServer.translate("T_LEVEL_COMPLETED_COUNT")
			% [levels_finished, map_manager.map_count]
		),
		"\n",
		TranslationServer.translate("T_STARS_COLLECTED") % [stars_collected],
		"\n",
		TranslationServer.translate("T_DEATHS") % [deaths]
	)


func goal_reached() -> void:
	levels_finished += 1
	display_stats()
	$LevelUp.play()
	if not map_manager.load_next_map():
		GameManager.end_game(
			(
				TranslationServer.translate("T_PIXEL_SIDE_SCROLLER_END_MESSAGE")
				% [levels_finished, deaths, stars_collected, star_count]
			),
			stars_collected + levels_finished * 2 - deaths
		)
