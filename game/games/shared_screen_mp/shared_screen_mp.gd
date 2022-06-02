extends Spatial

onready var input_manager = $InputManager
onready var player_manager = $PlayerManager
onready var network = $Network
onready var players = $Players


func _ready():
	load_map("test_map")
	player_manager.add_player(-1)  # spawn player one


func load_map(map_name: String):
	assert(map_name != "", "map_name is empty")
	var map = load("res://games/shared_screen_mp/maps/" + map_name + ".tscn").instance()
	map.name = "Map"
	add_child(map)


func close():
	network.leave()
	GameManager.end_game("")


func _on_Close_pressed():
	close()
