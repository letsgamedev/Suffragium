extends Spatial

var player_pawns: Array = []


func _ready():
	add_player()  # spawn player one


func add_player(device_id: int = -1):
	var pawn = spawn_pawn()
	pawn.input_handler.assigned_device_id = device_id
	player_pawns.append(pawn)


func remove_player(pawn):
	var pawn_idx: int = player_pawns.find(pawn)
	if pawn_idx == -1:
		print("ERROR:main:remove_player():pawn not found = ", pawn)
		return
	player_pawns.remove(pawn_idx)
	pawn.queue_free()


func spawn_pawn():
	var pawn = load("res://games/shared_screen_mp/pawn/pawn.tscn").instance()
	$Map.add_child(pawn)
	return pawn
