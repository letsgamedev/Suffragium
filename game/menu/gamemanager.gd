extends Node

## first %s is folder_name (same as game_id)
## second %s is the file path relative to the game folder
const GAME_FILE = "res://games/%s/%s"

var _games := {}  # type: Dictionary[String, ConfigFile]
var _game_displays := {}  # type: Dictionary[String, gamedisplay]

var _preview_scene := preload("res://menu/gamedisplay.tscn")
var _last_loaded_game = null
var _started_playing_game = null

onready var _grid := $mainmenu/ScrollContainer/GridContainer
onready var _main := $mainmenu
onready var _data_manager = load("res://menu/data_manager.gd").new()


func _ready():
	_find_and_load_games()
	_build_menu()


func get_current_game():
	return null if _last_loaded_game == null else _games[_last_loaded_game]


func load_game(game_cfg: ConfigFile):
	# load the games main scene
	var scene_path := (
		GAME_FILE
		% [
			game_cfg.get_meta("folder_name"),
			game_cfg.get_value("game", "main_scene"),
		]
	)
	var scene = load(scene_path)
	if scene == null:
		# TODO: Error handling could be better
		prints("Error: Game should specify correct main_scene, but was: ", scene_path)
		return ERR_FILE_BAD_PATH

	var err := get_tree().change_scene_to(scene)
	if err != OK:
		prints("Error", err)
		return err
	game_started(game_cfg.get_meta("folder_name"))
	_main.hide()
	return OK


func handle_error(err: int, err_msg: String = "", formats: Array = []) -> void:
	if err == OK:
		return
	if err_msg == "":
		push_error("Error %s" % err)
		return
	if formats:
		err_msg = err_msg % formats
	push_error("Error %s - %s" % [err, err_msg])


func game_started(game_id):
	_last_loaded_game = game_id
	_started_playing_game = OS.get_ticks_msec()


## Save the changes to the Dictionary returned by get_game_data()
## This method is automatically called when a game ends.
func save_game_data():
	assert(_last_loaded_game != null)  # this should only be called if _last_loaded_game is set
	_data_manager.save_game_data(get_current_player(), _last_loaded_game)


## Get the game data for the current player and the current game.
## To save data. Just modify the returned Dictionary and call save_game_data().
func get_game_data() -> Dictionary:
	assert(_last_loaded_game != null)
	return _data_manager.get_game_data(get_current_player(), _last_loaded_game)


func get_current_player() -> String:
	return "p"  # in future add here more logic


## Get the time the current player played the currently running game last.
func get_last_played(game_id = null):
	game_id = _last_loaded_game if game_id == null else game_id
	assert(game_id != null)
	return _data_manager.get_last_played(get_current_player(), game_id)


## Get time the current player played the currently running game.
func get_played_time(game_id = null) -> float:
	game_id = _last_loaded_game if game_id == null else game_id
	assert(game_id != null)
	return _data_manager.get_played_time(get_current_player(), game_id)


## Get the highscore of the current player for the currently running game.
## The score you would expect is available under the "score" key in the returned Dictionary.
func get_highscore(game_id = null) -> Dictionary:
	game_id = _last_loaded_game if game_id == null else game_id
	if not game_id:  # game_id should be the folder_name, not null or ""
		return {"score": null}
	var highscore = _data_manager.get_highscore(get_current_player(), game_id)
	if highscore == null:
		return {"score": null}
	return highscore


func pause_game():
	if _last_loaded_game == null or _started_playing_game == null:
		return
	_data_manager.game_ended(
		get_current_player(), _last_loaded_game, _started_playing_game, {"score": null}
	)  # save everything except the score
	_started_playing_game = null


##  return to the level select (if _change_scene is true)
func end_game(message := "", score = null, _change_scene := true):
	if _change_scene:
		var err = get_tree().change_scene("res://menu/empty_szene.tscn")
		if err != OK:
			prints("Error", err)
			return
		_main.show()

	assert(_last_loaded_game != null)  # should always be set here

	if not score is Dictionary:
		score = {"score": score}

	_data_manager.game_ended(get_current_player(), _last_loaded_game, _started_playing_game, score)

	_game_displays[_last_loaded_game].update_text()

	_last_loaded_game = null
	_started_playing_game = null

	# this behavior is subject to change
	if message:
		OS.alert(message)


# build the menu from configs in _games
func _build_menu():
	for c in _grid.get_children():
		c.queue_free()
	_main.show()

	#making the buttons
	for game_id in _games.keys():
		var display = _preview_scene.instance()
		_grid.add_child(display)
		display.setup(_games[game_id])
		_game_displays[game_id] = display


## go through every folder inside res://games/ and try to load the game.cfg into _games
func _find_and_load_games():
	_games.clear()
	var dir = Directory.new()
	if dir.open("res://games") == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var err := _load_game_cfg_file(file_name)
				if err != OK:
					prints("Error loading game cfg:", err)

			file_name = dir.get_next()


# load a config file into _games
func _load_game_cfg_file(folder_name: String) -> int:
	var config := ConfigFile.new()
	var err := config.load(GameManager.GAME_FILE % [folder_name, "game.cfg"])
	if err != OK:
		return err
	config.set_meta("folder_name", folder_name)
	_games[folder_name] = config
	return OK
