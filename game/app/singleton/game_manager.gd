extends Node

## first %s is folder_name (same as game_id)
## second %s is the file path relative to the game folder
const GAME_FILE_PATH_TEMPLATE = "res://games/%s/%s"

var _menu_path = "res://app/scenes/menu.tscn"
var _games_folder_path = "res://games"
var _games = []

var _current_game = null
var _current_game_config = null
var _current_game_start_time = null
var _pause_menu = null

onready var res_pause_menu = preload("res://app/pause_menu/pause_menu.tscn")

onready var _data_manager = load("res://app/scenes/data_manager.gd").new()


func _ready():
	_load_game_configs()


func _notification(what: int):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if _current_game:
			end_game()
		get_tree().quit()


func make_game_file_path(game_id: String, file_name: String) -> String:
	return GAME_FILE_PATH_TEMPLATE % [game_id, file_name]


func get_games() -> Array:
	return _games.duplicate()


func load_game(game_config: ConfigFile):
	var game_id = game_config.get_meta("folder_name")
	var main_scene = game_config.get_value("game", "main_scene")
	var scene_path := make_game_file_path(game_id, main_scene)
	var err = _change_scene(scene_path)
	if err == OK:
		_game_started(game_config)
		_pause_menu = res_pause_menu.instance()
		get_tree().get_root().add_child(_pause_menu)


func end_game(message: String = "", score = null):
	if not _current_game:
		push_error("called end_game, but no game loaded")
		return
	_data_manager.game_ended(
			PlayerManager.get_current_player(), _current_game, _current_game_start_time, score
	)
	_current_game = null
	_current_game_config = null
	_current_game_start_time = null
	if is_instance_valid(_pause_menu):
		_pause_menu.queue_free()
		_pause_menu = null
	_change_scene(_menu_path)
	# this behavior is subject to change
	if message:
		OS.alert(message)


## Save the changes to the Dictionary returned by get_game_data()
## This method is automatically called when a game ends.
func save_game_data():
	assert(_current_game != null)
	_data_manager.save_game_data(PlayerManager.get_current_player(), _current_game)


## Get the game data for the current player and the current game.
## To save data. Just modify the returned Dictionary and call save_game_data().
func get_game_data() -> Dictionary:
	assert(_current_game != null)
	return _data_manager.get_game_data(PlayerManager.get_current_player(), _current_game)


## Get the last time the current player played the game with game_id
func get_time_last_played(game_id: String = _current_game):
	assert(game_id != null)
	return _data_manager.get_last_played(PlayerManager.get_current_player(), game_id)


## Get playtime the current player played the game with game_id
func get_playtime(game_id: String = _current_game) -> float:
	assert(game_id != null)
	return _data_manager.get_played_time(PlayerManager.get_current_player(), game_id)


## Get the highscore of the current player for the game with game_id
## The score you would expect is available under the "score" key in the returned Dictionary.
func get_highscore(game_id: String = _current_game) -> Dictionary:
	if not game_id:
		return {}
	var highscore = _data_manager.get_highscore(PlayerManager.get_current_player(), game_id)
	if highscore == null:
		return {}
	return highscore


func pause_game():
	if _current_game == null or _current_game_start_time == null:
		return
	# save everything except the score
	_data_manager.game_ended(
		PlayerManager.get_current_player(), _current_game, _current_game_start_time, {"score": null}
	)
	_current_game_start_time = null


func unpause_game():
	_game_started(_current_game_config)


func restart_game():
	var game_config = _current_game_config
	end_game()
	load_game(game_config)


# loads the game.cfg for every folder in _games_folder_path and adds it to _games
func _load_game_configs():
	var dir = Directory.new()
	if dir.open(_games_folder_path) != OK:
		push_error("Could not open directory %s" % _games_folder_path)
		return
	dir.list_dir_begin(true)
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			_load_game_config_file(file_name)
		file_name = dir.get_next()


# load a config file into _games
func _load_game_config_file(folder_name: String):
	var config_file = ConfigFile.new()
	var config_path = GameManager.GAME_FILE_PATH_TEMPLATE % [folder_name, "game.cfg"]
	var err = config_file.load(config_path)
	if err:
		push_error("Could not load game config at path '%s'" % config_path)
		return
	config_file.set_meta("folder_name", folder_name)
	_games.push_back(config_file)


func _change_scene(scene_path: String):
	var err = get_tree().change_scene(scene_path)
	if err:
		push_error("Could not change scene to '%s' (Code: %s)" % [scene_path, err])
		return err
	return OK


func _game_started(game_config: ConfigFile):
	_current_game = game_config.get_meta("folder_name")
	_current_game_config = game_config
	_current_game_start_time = OS.get_ticks_msec()
