extends Node

## Controlls join/leave from local and remote players

var local_player_pawns: Array = []

onready var _main = get_tree().current_scene


func add_player(device_id: int, spawn_translation: Vector3 = Vector3(0, 0, 0)):
	var pawn = spawn_pawn(spawn_translation)
	pawn.input_handler.assigned_device_id = device_id
	randomize()
	pawn.color = Color(randf(), randf(), randf())
	pawn.add_to_group("LOCAL")
	local_player_pawns.append(pawn)
	if _main.network.is_net_connected():
		var local_unique_id: int = _main.network.local_unique_id_counter
		pawn.name = _main.network.make_peer_pawn_name(
			_main.network.get_unique_id(), local_unique_id
		)
		pawn.set_network_master(_main.network.get_unique_id())
		var net_id: int = _main.network.get_unique_id()
		var pawn_idx: int = local_unique_id
		rpc("add_remote_player", net_id, pawn_idx, pawn.get_info(), pawn.translation)


func remove_player(pawn):
	var pawn_idx: int = local_player_pawns.find(pawn)
	if pawn_idx == -1:
		print("ERROR:main:remove_player():pawn not found = ", pawn)
		return
	var pawn_name = pawn.name
	local_player_pawns.remove(pawn_idx)
	pawn.queue_free()
	if _main.network.is_net_connected():
		rpc("remove_remote_player", pawn_name)


remote func add_remote_player(
	net_id: int, pawn_idx: int, pawn_data: Dictionary, spawn_translation: Vector3 = Vector3(0, 0, 0)
):
	if _main.network.get_unique_id() == net_id:
		return
	var pawn = spawn_pawn(spawn_translation)
	pawn.input_handler.assigned_device_id = -2
	pawn.name = _main.network.make_peer_pawn_name(net_id, pawn_idx)
	pawn.set_network_master(net_id)
	pawn.color = pawn_data.color
	pawn.add_to_group("REMOTE")


remote func remove_remote_player(pawn_name: String):
	if _main.network.is_net_connected():
		if _main.network.get_unique_id() == int(pawn_name.split("_")[0]):
			return
	_main.players.get_node(pawn_name).queue_free()


func spawn_pawn(spawn_translation: Vector3):
	var pawn = load("res://games/shared_screen_mp/pawn/pawn.tscn").instance()
	var offset_range: float = 0.2
	var offset: Vector3 = Vector3(
		rand_range(-offset_range, offset_range), 0, rand_range(-offset_range, offset_range)
	)
	pawn.translation = spawn_translation + offset
	_main.players.add_child(pawn)
	return pawn
