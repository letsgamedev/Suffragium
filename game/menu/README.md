# Information for Contributers

## GameManager
The GameManager keeps track of all minigames and starts/stops them when needed.  
It also has a rudimentary game selection menu that uses the Gamedisplays.  

## GameDisplay
Is used my the Gamemanagers game menu to show what the game is about.  
It has a button to load the game & a popup for more detailed infos but no logic beyond that.  


# API
## GameManager

* **`load_game(game_cfg: ConfigFile)`**  
  Loads the game specified by the config file.

* **`end_game(message:String="", _status=null)`**  
  Ends the game and displays `message`. This behaviour will change in the future.  
  `_status` isn't used at the moment. It is meant for the score the player achived.  

* **`_build_menu()`**  
  Creates a menu using Gamedisplays for the cached `game.cfg` files in `_games`  

* **`_find_games()`**   
  Searches every folder inside "res://games/" for files called `game.cfg` and caches them in   `_games` using `_load_game_cfg_file()`.  
  `_games` is cleared at the start.  

* **`_load_game_cfg_file(path: String)`**  
    Loads any config file into `_games`.  
    Any valid .cfg will be loaded. There are no checks to prevent incorect data from loading.  

## GameDisplay
* signal **`pressed(game_file)`**  
    Is emitted when any load buttons of the display are pressed.  
    `game_file` is the config used when setup was called.  

* **`setup(game_cfg: ConfigFile)`**  
    Loads the data from the given `game.cfg` into the correct labels.  
