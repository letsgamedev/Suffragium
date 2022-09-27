# Information for Contributers

## Game-Id
If in the code a `game_id` is mentioned, this is the name of the folder where the game is in.

## GameManager
The GameManager keeps track of all minigames and starts/stops them when needed.  
It also has a rudimentary game selection menu that uses the GameDisplays.

## GameDisplay
Is used my the GameManagers game menu to show what the game is about.  
It has a button to load the game & a popup for more detailed infos but no logic beyond that.

## PauseMenu
The PauseMenu is autoloaded like GameManager. It will pause the game using `get_tree().paused`.  
It uses `_input()` as a trigger so it won't interfere with other UI or gameplay.

# API
## GameManager

* **`load_game(game_cfg: ConfigFile)`**  
  Loads the game specified by the config file.

* **`end_game(message: String = "", score = null)`**  
  Ends the game and displays `message`. This behaviour will change in the future.  
  `score` is the score the player achived while playing the game. Leave it out if the game has no scores.

* **`handle_error(err: int, err_msg: String = "", formats: Array = [])`**  
  Prints an error if `err != OK`.  
  If `err_msg` is specified `"Error {err} - {err_msg % formats}"` will be printed.  
  If no `err_msg` is specified `"Error {err}"` will be printed.

* **`get_game_data()`**  
  Only use this while in a game.
  This returns a Dictionary in which games can write data. This will be saved to disk when the game ends.
  Use this as persistent storage.

* **`save_game_data()`**  
  Only use this while in a game.
  This will be automatically called in `end_game()`.
  This saves the changes made to the Dictionary returned by `get_game_data()`

* **`get_current_player()`**  
  This should in future return the name of the current player as String. Currently it just returns "p".

* **`get_last_played(game_id = null)`**  
  Only use this while in a game or specify game_id.
  Get the time the player returned by `get_current_player()` last played a game.

* **`get_played_time(game_id = null)`**  
  Only use this while in a game or specify game_id.
  Get the time the player returned by `get_current_player()` already played a game.

* **`get_highscore(game_id = null)`**  
  Only use this while in a game or specify game_id.
  Get the highscore of the player returned by `get_current_player()` in the game.  
  The returned Dictionary has a "score" key, that contains the real score.

* **`_build_menu()`**  
  Creates a menu using GameDisplays for the cached `game.cfg` files in `_games`

* **`_find_and_load_games()`**  
  Searches every folder inside "res://games/" for files called `game.cfg` and caches them in `_games` using `_load_game_cfg_file()`.  
  `_games` is cleared at the start.

* **`_load_game_cfg_file(folder_name: String)`**  
  Loads any config file into `_games`.  
  Any valid .cfg will be loaded. There are no checks to prevent incorect data from loading.


## GameDisplay
* signal **`pressed(game_file)`**  
  Is emitted when any load buttons of the display are pressed.  
  `game_file` is the config used when setup was called.

* **`setup(game_cfg: ConfigFile)`**  
  Loads the data from the given `game.cfg` into the correct labels.

## PauseMenu
* signal **`pause_menu_opened`**  
  emitted when the menu opens but before `get_tree().paused` is changed.
* signal **`pause_menu_closed`**
  emitted when the menu closes but before `get_tree().paused` is changed.
* signal **`custom_button_pressed(text)`**  
  emitted when a custom button is pressed. This includes those added by `add_custom_button()` and those automatically added by `add_custom_page()`
* **`_update_menu()`**  
  Private function to configure the buttons when the menu is shown.
* **`add_custom_button(text: String, idx := -1)`**  
  Adds a custom button to the pause menu between the restart and back to menu button.  
  idx will place it at the given position between the custom buttons.
* **`add_custom_page(page: Control, page_name: String)`**  
  Adds the given control node in the pause menu and a button to show it.
* **`clear_custom_content()`**  
  Frees all custom buttons and pages.
* **`remove_custom_page(page_name: String)`**  
  Removes a custom page if it exists.
* **`remove_custom_button(text: String)`**  
  Removes a custom button if it exists.
* **`show()`**  
  Shows the pause menu. Use this to open the menu from code.
* **`hide()`**  
  Hides the pause menu. Use this to close the menu from code.
* **`is_open()`**  
  Returns `true` if the menu is open.
* **`get_custom_pages()`**  
	Returns a Dictionary with the page names as keys and the instanced nodes as values
* **`get_custom_buttons()`**  
	Returns a Dictionary with the button texts as keys and the instanced buttons as values
