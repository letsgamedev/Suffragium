# How to add you own Minigame - A Step-by-step Guide

## 1. Choose a folder for your minigame
All files related to your game only go into a folder inside `res://games/` with a random name you choose. You shouldn't rename it after the game is first merged. 
There are no rules what to call it. A good idea is to use your name and the name of your game (ex. `asecondguy_assimilator`) to avoid any accidental collisions.

## 2. Make a game.cfg
The game.cfg file resides in your minigame folder. It defines how your game is loaded and displayed in the game selection menu.
You can find all relevant keys in this document.
If you are unsure copy the game.cfg from the testgame and change the values to your need.
It will always contain all required and optional settings clearly marked.

## 3. Make your game work
* GameManager is always available in every script and has useful functions(like `end_game()`). A list of these functions can be found in this document or the full list with all functions in [this README](../../menu/README.md)
* Don't add `Autoload` scripts. They are loaded on startup and run all the time so it is bad practice to use one in a minigame.
* The scene you defined in `game.cfg` will be loaded with `get_tree().change_scene()`. So It'll work like it is the main scene.
* To return to the game selection use `GameManager.end_game("This is the end message")`

# game.cfg keys
* Section: `game`
  * Choose a memorable name
      `name="Balloon pop"`
  * Description supports bbcode. Say what your game is about.
      `desc="Pop the balloons of the right [color=blue]color[/color]"`
  * These paths are relative to the game folder.
      `main_scene="balloonPop.tscn"`
      `icon="balloon.png"`
  * Version has no effect. But it might be shown in debug menus.
      `version="1.0"`
  * Put your name here. Has no effect.
      `creator="ASecondGuy"`

# Useful functions
* **`end_game(message: String="", _status=null)`**
    Ends the game and displays the message. This behaviour will change in the future.
    `_status` isn't used at the moment. It is meant for the score the player achived.
* `load_game(game_cfg: ConfigFile)`
    Loads the game specified by the config file.