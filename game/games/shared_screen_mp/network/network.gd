extends "res://games/shared_screen_mp/network/network_basic.gd"

onready var main = get_tree().current_scene


func _ready():
	connect("disconnected", self, "_on_disconnected")


func make_peer_pawn_name(net_id: int, pawn_idx: int) -> String:
	return str(net_id) + "_" + str(pawn_idx)


func is_own_pawn(pawn) -> bool:
	if is_net_connected():
		if get_unique_id() == int(pawn.name.split("_")[0]):
			return true
	return false


func _on_peer_connected(id: int):
	for local_pawn in main.player_manager.local_player_pawns:
		var net_id: int = get_unique_id()
		var pawn_idx: int
		if int(local_pawn.name.split("_")[0]) != get_unique_id():
			pawn_idx = main.player_manager.local_unique_id_counter
			local_pawn.name = make_peer_pawn_name(net_id, pawn_idx)
		else:
			pawn_idx = int(local_pawn.name.split("_")[1])
		var pawn_info: Dictionary = {
			"idx": pawn_idx,
			"color": local_pawn.color,
		}
		main.player_manager.rpc_id(id, "add_remote_player", net_id, pawn_idx, pawn_info)
	emit_signal("peer_connected", id)


func _on_peer_disconnected(id: int):
	for remote_pawn in main.players.get_children():
		if int(remote_pawn.name.split("_")[0]) == id:
			main.player_manager.remove_remote_player(remote_pawn.name)
	emit_signal("peer_disconnected", id)


func _on_server_disconnected():
	_remove_all_peer_pawns()
	emit_signal("server_disconnected")


func _on_disconnected():
	_remove_all_peer_pawns()


func _remove_all_peer_pawns():
	for remote_pawn in main.players.get_children():
		if remote_pawn.is_in_group("REMOTE"):
			main.player_manager.remove_remote_player(remote_pawn.name)
