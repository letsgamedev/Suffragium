extends Control

onready var main = get_tree().current_scene

onready var ip_node: TextEdit = $VBox/IpContainer/Ip
onready var port_node: TextEdit = $VBox/PortContainer/Port
onready var status: Label = $VBox/Buttons/Status
onready var host: Button = $VBox/Buttons/Host
onready var join: Button = $VBox/Buttons/Join
onready var leave: Button = $VBox/Buttons/Leave


func _ready():
	_show_host_join_button()


func _on_Host_pressed():
	_connect_net_signals()
	main.network.host(int(port_node.text), 4)


func _on_Join_pressed():
	_connect_net_signals()
	status.text = "connecting ..."
	main.network.join(ip_node.text, int(port_node.text))


func _on_Leave_pressed():
	main.network.leave()


func _connect_net_signals():
	if main.network.is_connected("connection_succeeded", self, "_on_connected"):
		return
	main.network.connect("connection_succeeded", self, "_on_connected")
	main.network.connect("connection_failed", self, "_on_connection_failed")
	main.network.connect("hosted", self, "_on_hosted")
	main.network.connect("server_disconnected", self, "_on_disconnected")
	main.network.connect("disconnected", self, "_on_disconnected")
	main.network.connect("error", self, "_on_error")


func _on_hosted():
	_show_leave_button()
	status.text = "server"


func _on_connected():
	_show_leave_button()
	status.text = "client"


func _on_disconnected():
	_show_host_join_button()
	status.text = "offline"


func _on_error(err: int):
	_show_host_join_button()
	status.text = "error " + _get_error_code_name(err)


func _on_connection_failed():
	_show_host_join_button()
	status.text = "connecting failed"


func _show_leave_button():
	host.hide()
	join.hide()
	leave.show()


func _show_host_join_button():
	host.show()
	join.show()
	leave.hide()


func _get_error_code_name(err: int):
	match err:
		20:
			return str(err) + " ERR_CANT_CREATE"
		22:
			return str(err) + " ERR_ALREADY_IN_USE"
		_:
			return str(err)
