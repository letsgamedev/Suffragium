extends VBoxContainer

const AI_PACKED_SCENE := preload("res://games/asecondguy_connect/ai.tscn")

@onready var _player_conf := $PC/HBox.get_children()
@onready var _game := $"../.."


func _on_Button_pressed():
	for conf in _player_conf:
		var player_id: int = _game.player_names.size()
		# setup anything type specific
		match conf.get_option():
			0:
				pass  #Manual Player. No setup required
			1:
				var ai = AI_PACKED_SCENE.instantiate()
				ai.player_id = player_id
				_game.add_child(ai)
# warning-ignore:return_value_discarded
				_game.connect(
					"chip_spawned", Callable(ai, "_on_chip_spawn").bind(), CONNECT_DEFERRED
				)
		#setup name
		_game.player_names.push_back(conf.get_name())
		_game.player_colors.push_back(conf.get_player_color())
	_game.start()
	hide()
