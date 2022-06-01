# How to add you own Minigame - A Step by step Guide

## 1. Chose a folder
All files related only to your game go into a folder inside `res://games/`. You shouldn't rename it after the game is first merged. 
There are no rules what to call it but a good idea is to use your name and the games name (ex. "asecondguy_assimilator") to avoid any accidental collisions.

## 2. Make a game.cfg
The game.cfg file resides in your Minigame's folder. It defines how your game is displayed. 
If you are unsure copy the game.cfg from the testgame and change the values.
It will always contain all required and optional settings clearly marked.

## 3. Make your game work
* GameManager is always available in every script and has useful functions. (like `end_game()`)
* Don't add `Autoload` scripts. They are loaded on startup and run all the time so it is bad practice to use one in a minigame.
* The scene you defined in `game.cfg` will be loaded with `get_tree().change_scene()`. So It'll work like it is the main scene.
* To return to the game selection use `GameManager.end_game("This is the end message")`
