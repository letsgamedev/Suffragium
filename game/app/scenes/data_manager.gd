extends Node

const SAVE_FILE_DIR = "user://savefiles/%s/%s/"

## type of _game_data_cache: Dictionary[String, Dictionary]
##                                  (file name) (the data)
var _game_data_cache := {}  # NEVER MODIFY THIS, IF YOU DON'T KNOW WHAT YOU ARE DOING!


## Save data to a file for the given game.
## This is a private function, don't use this in a game
func _save_data(player: String, file_name: String, data, game_id: String) -> int:
	var cache_key := player + "/" + game_id + "/" + file_name
	var directory := SAVE_FILE_DIR % [player, game_id]
	var dir_access = DirAccess.open("user://")
	var err: int = dir_access.make_dir_recursive(directory)
	if err != OK:
		return err
	if not cache_key in _game_data_cache:
		return OK
	_game_data_cache[cache_key] = data
	var file = FileAccess.open(directory + file_name + ".json", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(_game_data_cache[cache_key]))
	file.close()
	return OK


## Load data from a file or _game_data_cache and return the data for the game.
## If something doesn't exist an empty Dictionary is returned, which is put in
## the correct location in the _game_data_cache Dictionary.
## This is a private function, don't use this in a game.
func _load_data(player: String, file_name: String, game_id: String) -> Dictionary:
	var cache_key := "%s/%s/%s" % [player, game_id, file_name]
	if cache_key in _game_data_cache:
		return _game_data_cache[cache_key]

	var directory := SAVE_FILE_DIR % [player, game_id]
	var dir = DirAccess.open("user://")
	Utils.handle_error(dir.make_dir_recursive(directory))

	_game_data_cache[cache_key] = {}  # populate with default
	# read saved data from a file
	var file = FileAccess.open(directory + file_name + ".json", FileAccess.READ)

	if file == null:
		return _game_data_cache[cache_key]

	var content = file.get_as_text()
	file.close()

	var json_converter = JSON.new()
	var parse_status: int = json_converter.parse(content)
	var parse_result = json_converter.get_data()
	if parse_status == OK:
		# put contents from file in the cache
		_game_data_cache[cache_key] = parse_result

	return _game_data_cache[cache_key]


## Get the game data for the current player and the current game.
## To save data. Just modify the returned Dictionary and call save_game_data().
func get_game_data(player: String, game_id: String) -> Dictionary:
	return _load_data(player, "game_data", game_id)


## Save the changes to the Dictionary returned by get_game_data()
## This method is automatically called when a game ends.
func save_game_data(player: String, game_id: String):
	Utils.handle_error(
		_save_data(player, "game_data", _load_data(player, "game_data", game_id), game_id),
		"Saving game data for player %s and game %s failed.",
		[player, game_id]
	)


class ScoreSorter:
	static func sort_scores_descending(a, b):
		if a["score"] == b["score"]:
			if "_time" in a and "_time" in b:
				# later time first
				return a["_time"] > b["_time"]
			return true  # doesn't matter
		# higher score first
		return a["score"] > b["score"]


## Handle data for the game that ended.
func game_ended(player: String, game_id: String, start_time, score_or_null):
	save_game_data(player, game_id)

	var data = _load_data(player, "game_meta_data", game_id)

	var current_time := Time.get_unix_time_from_system()

	data["last_played"] = current_time

	if start_time != null:
		if not "played_time" in data:
			data["played_time"] = 0
		data["played_time"] += (Time.get_ticks_msec() - start_time) / 1000.0

	if score_or_null != null:
		assert(score_or_null is int)
		var score_dict = {"score": score_or_null}
		score_dict["_time"] = current_time
		if not "scores" in data:
			data["scores"] = []
		data["scores"].append(score_dict)
		data["scores"].sort_custom(Callable(ScoreSorter, "sort_scores_descending"))

	Utils.handle_error(_save_data(player, "game_meta_data", data, game_id))


## Get the highscore of the player for the game.
func get_highscore(player: String, game_id: String):
	var data = _load_data(player, "game_meta_data", game_id)

	if not "scores" in data or data["scores"].size() == 0:
		return null

	return data["scores"][0]


## Get time the player played the game.
func get_played_time(player: String, game_id: String) -> float:
	var data = _load_data(player, "game_meta_data", game_id)
	if not "played_time" in data:
		return 0.0
	return data["played_time"]


## Get the time the player played the game last time.
func get_last_played(player: String, game_id: String):
	var data = _load_data(player, "game_meta_data", game_id)
	if not "last_played" in data:
		return null
	return data["last_played"]
