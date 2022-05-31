extends Spatial

var player_pawns: Array = []


func _ready():
	add_player(-1)  # spawn player one


func add_player(device_id: int, spawn_translation: Vector3 = Vector3(0, 0, 0)):
	var pawn = spawn_pawn(spawn_translation)
	pawn.input_handler.assigned_device_id = device_id
	player_pawns.append(pawn)


func remove_player(pawn):
	var pawn_idx: int = player_pawns.find(pawn)
	if pawn_idx == -1:
		print("ERROR:main:remove_player():pawn not found = ", pawn)
		return
	player_pawns.remove(pawn_idx)
	pawn.queue_free()


func spawn_pawn(spawn_translation: Vector3):
	var pawn = load("res://games/shared_screen_mp/pawn/pawn.tscn").instance()
	var offset_range: float = 0.2
	var offset: Vector3 = Vector3(
		rand_range(-offset_range, offset_range), 0, rand_range(-offset_range, offset_range)
	)
	pawn.translation = spawn_translation + offset
	$Map.add_child(pawn)
	return pawn
