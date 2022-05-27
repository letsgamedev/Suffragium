extends Node

var _games = []
var _preview_scene := preload("res://menu/gamedisplay.tscn")

onready var _grid := $mainmenu/ScrollContainer/GridContainer
onready var _main := $mainmenu

func _ready():
	_find_games()
	_build_menu()


func load_game(game_cfg:ConfigFile):
	# load the games main scene
	var scene = load(game_cfg.get_meta("folder_path")+game_cfg.get_value("game", "main_scene"))
	
	var err := get_tree().change_scene_to(scene)
	if err != OK:
		prints("Error", err)
		return
	_main.hide()


# return to the level select
func end_game(message:="", _status=null):
	get_tree().change_scene("res://menu/emptySzene.tscn")
	_main.show()
	# this behavior is subject to change
	if !message.empty(): 
		OS.alert(message)


# build the menu from configs in _games
func _build_menu():
	for c in _grid.get_children():
		c.queue_free()
	_main.show()
	
	#making the buttons
	for game in _games:
		var display = _preview_scene.instance()
		display.setup(game)
		display.connect("pressed", self, "load_game")
		_grid.add_child(display)


# go through every folder inside res://games/ and try to load the game.cfg into _games
func _find_games():
	_games.clear()
	var dir = Directory.new()
	if dir.open("res://games") == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var game_path = "res://games/" + file_name + "/game.cfg"
				
				var err := _load_game_cfg_file(game_path)
				if err != OK:
					prints("Error loading game cfg:", err)
				
			file_name = dir.get_next()


# load a config file into _games
func _load_game_cfg_file(path:String)->int:
	var f := ConfigFile.new()
	var err := f.load(path)
	if err != OK: return err
	f.set_meta("folder_path", path.get_base_dir()+"/")
	_games.push_back(f)
	return OK
