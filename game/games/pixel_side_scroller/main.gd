extends Node2D

var current_map = null
var player = null

onready var camera = "Camera2D"


func _ready():
	load_map("map")
	spawn_player()


func load_map(name_name: String):
	if current_map:
		current_map.queue_free()
	var new_map = load("res://games/pixel_side_scroller/maps/" + name_name + ".tscn").instance()
	current_map = new_map
	add_child(new_map)


func spawn_player():
	var spawn = current_map.get_node("Spawn")
	if !is_instance_valid(spawn):
		return
	if player:
		player.queue_free()
	var new_player = load("res://games/pixel_side_scroller/pawns/character/character.tscn").instance()
	player = new_player
	player.position = spawn.position
	add_child(new_player)


func goal_reached():
	GameManager.end_game("Best Game Ever. 5/7 Rating")
