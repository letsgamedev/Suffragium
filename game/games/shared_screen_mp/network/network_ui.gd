extends Control

onready var _main = get_tree().current_scene

onready var _ip_node: TextEdit = $VBox/IpContainer/Ip
onready var _port_node: TextEdit = $VBox/PortContainer/Port
onready var _status: Label = $VBox/Buttons/Status
onready var _host: Button = $VBox/Buttons/Host
onready var _join: Button = $VBox/Buttons/Join
onready var _leave: Button = $VBox/Buttons/Leave


func _ready():
	_show_host_join_button()


func _on_Host_pressed():
	_connect_net_signals()
	_main.network.host(int(_port_node.text), 4)


func _on_Join_pressed():
	_connect_net_signals()
	_status.text = "connecting ..."
	_main.network.join(_ip_node.text, int(_port_node.text))


func _on_Leave_pressed():
	_main.network.leave()


func _connect_net_signals():
	if _main.network.is_connected("connection_succeeded", self, "_on_connected"):
		return
	_main.network.connect("connection_succeeded", self, "_on_connected")
	_main.network.connect("connection_failed", self, "_on_connection_failed")
	_main.network.connect("hosted", self, "_on_hosted")
	_main.network.connect("server_disconnected", self, "_on_disconnected")
	_main.network.connect("disconnected", self, "_on_disconnected")
	_main.network.connect("error", self, "_on_error")


func _on_hosted():
	_show_leave_button()
	_status.text = "server"


func _on_connected():
	_show_leave_button()
	_status.text = "client"


func _on_disconnected():
	_show_host_join_button()
	_status.text = "offline"


func _on_error(err: int):
	_show_host_join_button()
	_status.text = "error " + _get_error_code_name(err)


func _on_connection_failed():
	_show_host_join_button()
	_status.text = "connecting failed"


func _show_leave_button():
	_host.hide()
	_join.hide()
	_leave.show()


func _show_host_join_button():
	_host.show()
	_join.show()
	_leave.hide()


func _get_error_code_name(err: int):
	match err:
		20:
			return str(err) + " ERR_CANT_CREATE"
		22:
			return str(err) + " ERR_ALREADY_IN_USE"
		_:
			return str(err)
