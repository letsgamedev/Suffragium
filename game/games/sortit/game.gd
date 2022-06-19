extends MarginContainer

const BLOCK_SCENE: PackedScene = preload("res://games/sortit/box.tscn")
const MAX_SCORE = 10

export(Vector2) var spawn_height = Vector2(40, 100)
export(int) var max_box_count = 50

var _box_count = 0

onready var _rng := RandomNumberGenerator.new()
onready var _spaw_areas = $BoxSpawnAreas.get_children()
onready var _players = $Players


func _ready():
	_rng.randomize()
	_players.spawn_players()
	$Viewports.create_viewports()
	# Start with 6 boxes
	for _i in range(0, 6):
		_spawn_box()


func _spawn_box():
	# Don't spawn more boxes if maxiumim count is reached
	if _box_count > max_box_count:
		return
	# Get random spawn area
	var spawn_area_index = _rng.randi_range(0, len(_spaw_areas) - 1)
	var spawn_area = _spaw_areas[spawn_area_index] as Spatial
	var spawn_origin = spawn_area.global_transform.origin
	var spawn_scale = spawn_area.scale
	# Spawn block inside picked spawn area
	var block: RigidBody = BLOCK_SCENE.instance()
	$Boxes.add_child(block)
	block.connect("despawn", self, "_on_box_despawn")
	var block_position = Vector3.ZERO
	block_position.x = _rng.randf_range(
		spawn_origin.x - spawn_scale.x, spawn_origin.x + spawn_scale.x
	)
	block_position.y = _rng.randf_range(spawn_height.x, spawn_height.y)
	block_position.z = _rng.randf_range(
		spawn_origin.z - spawn_scale.z, spawn_origin.z + spawn_scale.z
	)
	block.global_transform.origin = block_position
	_box_count += 1


func _end_game():
	var best_player_index = _players.get_best_player()[0]
	GameManager.end_game("Player %d won" % (best_player_index + 1))


func _on_box_despawn(_number: int):
	_box_count -= 1


func _on_spawn_timer_timeout():
	_spawn_box()
	# Check the highest score every couple of seconds and end the game, if the maximum score is reached
	var highest_score = _players.get_best_player()[1]
	if highest_score == MAX_SCORE:
		_end_game()


func _on_end_timer_timeout():
	_end_game()
