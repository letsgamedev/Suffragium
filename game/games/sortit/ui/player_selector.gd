extends PanelContainer
signal start_game(player_inputs)

const HELP_POPUP_BACKGROUND_BRIGHTNESS = 0.4

var _current_input_player_selctor_index = 0
var _player_inputs = []
var _has_been_played = true

@onready var _main_content_container: MarginContainer = $MarginContainer
@onready var _players = $MarginContainer/VBoxContainer/MarginContainer/Players
@onready var _back_button: Button = $MarginContainer/VBoxContainer/Buttons/HBoxContainer/BackButton
@onready var _play_button: Button = $MarginContainer/VBoxContainer/Buttons/HBoxContainer2/PlayButton
# Path is to long, but cannot cleanly be split into multiple lines to avoid line length limit
# gdlint: ignore=max-line-length
@onready var _help_button: Button = $MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/HelpButton


func _ready():
	# Open help screen, if game has not been played yet
	var game_data = GameManager.get_game_data()
	if not game_data.has("played") or game_data["played"] == false:
		_on_help_button_up()
		_has_been_played = false

	for i in range(_players.get_child_count()):
		var player_select = _players.get_children()[i]
		player_select.connect("got_input", Callable(self, "_on_player_select_got_input"))


func _on_player_select_got_input(input_type: Array):
	# Don't accept input, if that input type is already used by annother player
	if _player_inputs.has(input_type):
		return
	_player_inputs.push_back(input_type)
	# Stop getting inputs from current selector
	var current_selector = _players.get_child(_current_input_player_selctor_index)
	current_selector.get_input = false
	# Don't display next input_selector, if its the last one
	if _current_input_player_selctor_index + 1 >= _players.get_child_count():
		return
	_current_input_player_selctor_index += 1
	# Display and get input to select the input method for the next player
	var next_selector = _players.get_child(_current_input_player_selctor_index)
	next_selector.display = true
	next_selector.get_input = true
	# Show back button and enable play button, if at least one player selected thier input scheme
	if _current_input_player_selctor_index > 0:
		_play_button.disabled = false
		_back_button.show()


func _on_back_button_up():
	# Reset/hide current selector
	var current_selector = _players.get_child(_current_input_player_selctor_index)
	_player_inputs.pop_back()
	if current_selector.get_input == false:
		current_selector.get_input = true
		return
	current_selector.get_input = false
	current_selector.display = false
	# Get input from last selector
	_current_input_player_selctor_index -= 1
	var old_selector = _players.get_child(_current_input_player_selctor_index)
	old_selector.get_input = true
	# Hide back button and disable play button, if at start
	if _current_input_player_selctor_index == 0:
		_play_button.disabled = true
		_back_button.hide()


func _on_play_button_up():
	# Mark game as played, to not show the help popup again by default
	var game_data = GameManager.get_game_data()
	if not _has_been_played:
		game_data["played"] = true
		GameManager.save_game_data()
	# Emit the start_game signal with the configured controls to actually start the game
	emit_signal("start_game", _player_inputs)


func _on_help_button_up():
	var pages := PauseMenu.get_custom_pages()
	if pages.has("T_HELP"):
		PauseMenu.pause()
		pages["T_HELP"].show()
		pages["T_HELP"].close_menu = true
