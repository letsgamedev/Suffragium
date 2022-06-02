extends Node

## Basic functionality for networking.

signal peer_connected(id)
signal peer_disconnected(id)
signal connection_succeeded
signal connection_failed
signal server_disconnected
signal hosted
signal disconnected
signal error(err)

var peer = NetworkedMultiplayerENet.new()


func _ready():
	peer.connect("peer_connected", self, "_on_peer_connected")
	peer.connect("peer_disconnected", self, "_on_peer_disconnected")
	peer.connect("connection_succeeded", self, "_on_connection_succeeded")
	peer.connect("connection_failed", self, "_on_connection_failed")
	peer.connect("server_disconnected", self, "_on_server_disconnected")


func host(port: int, max_players: int):
	var err = peer.create_server(port, max_players)
	if err:
		print("Error:network:host = ", err)
		emit_signal("error", err)
		return
	get_tree().network_peer = peer
	emit_signal("hosted")


func join(ip: String, port: int):
	var err = peer.create_client(ip, port)
	if err:
		print("Error:network:join = ", err)
		emit_signal("error", err)
		return
	get_tree().network_peer = peer


func leave():
	peer.close_connection()
	get_tree().network_peer = null
	emit_signal("disconnected")


func get_unique_id() -> int:
	return get_tree().get_network_unique_id()


func is_net_connected() -> bool:
	if (
		get_tree().network_peer != null
		and (
			get_tree().network_peer.get_connection_status()
			== NetworkedMultiplayerPeer.CONNECTION_CONNECTED
		)
	):
		return true
	return false


func _on_peer_connected(id: int):
	emit_signal("peer_connected", id)


func _on_peer_disconnected(id: int):
	emit_signal("peer_disconnected", id)


func _on_connection_succeeded():
	emit_signal("connection_succeeded")


func _on_connection_failed():
	emit_signal("connection_failed")


func _on_server_disconnected():
	emit_signal("server_disconnected")
