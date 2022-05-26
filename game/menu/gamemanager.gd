extends Node

var _games = []
var _preview_scene := preload("res://menu/gamedisplay.tscn")

onready var _grid := $mainmenu/ScrollContainer/GridContainer
onready var _main := $mainmenu

func _ready():
	_find_games()
	build_menu()


func load_game(game_cfg:ConfigFile):
	# load the games main scene
	var scene = load(game_cfg.get_meta("folder_path")+game_cfg.get_value("game", "main_scene"))
	
	var err := get_tree().change_scene_to(scene)
	if err != OK:
		prints("Error", err)
		return
	_main.hide()



func _find_games():
	_games.clear()
	var dir = Directory.new()
	if dir.open("res://games") == OK:
		dir.list_dir_begin(true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				var game_path = "res://games/" + file_name + "/game.cfg"
				
				load_game_cfg_file(game_path)
			file_name = dir.get_next()

func build_menu():
	for c in _grid.get_children():
		c.queue_free()
	_main.show()
	
	#making the buttons
	for game in _games:
		var display = _preview_scene.instance()
		display.setup(game)
		display.connect("pressed", self, "load_game", [game])
		_grid.add_child(display)




func load_game_cfg_file(path:String):
	var f := ConfigFile.new()
	if f.load(path) != OK: return
	f.set_meta("folder_path", path.get_base_dir()+"/")
	_games.push_back(f)
	return false




