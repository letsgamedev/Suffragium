class_name GameDisplay

extends MarginContainer

var game_file: ConfigFile
onready var _load_btn_main: Button = $VBoxContainer/loadbutton
onready var _load_btn_dialog: Button = $InfoDialog.add_button("load")


func setup(game_cfg: ConfigFile):
	game_file = game_cfg

	$VBoxContainer/Label.text = game_cfg.get_value("game", "name")
	update_text()

	var icon_path = (
		GameManager.GAME_FILE
		% [game_cfg.get_meta("folder_name"), game_cfg.get_value("game", "icon")]
	)
	var icon: Texture = load(icon_path)
	if icon == null:
		prints("Game icon with path '", icon_path, "' could not be found.")
		icon = load("res://icon.png")
	$VBoxContainer/TextureRect.texture = icon

	#setup of info Dialog
	##setup buttons
	GameManager.handle_error(
		$InfoButton.connect("pressed", $InfoDialog, "popup_centered_minsize", [Vector2(500, 250)])
	)

	GameManager.handle_error(_load_btn_dialog.connect("pressed", $InfoDialog, "hide"))
	GameManager.handle_error(_load_btn_dialog.connect("pressed", self, "_on_loadbutton_pressed"))
	##setup text
	$InfoDialog/Container/Label.text = game_cfg.get_value("game", "name")
	$InfoDialog/Container/TextureRect.texture = icon
	$InfoDialog/Container/descCont/desclab.bbcode_text = game_cfg.get_value("game", "desc")
	var text = ""
	text += "Author: " + game_cfg.get_value("game", "creator") + "\n"
	text += "Version: " + game_cfg.get_value("game", "version") + "\n"
	$InfoDialog/Container/descCont/Statslab.text = text


func disable():
	_load_btn_main.disabled = true
	_load_btn_dialog.disabled = true


func format_date(unix_time: int):
	var dt = OS.get_datetime_from_unix_time(unix_time)
	return (
		"%04d-%02d-%02d %02d:%02d:%02d UTC"
		% [dt["year"], dt["month"], dt["day"], dt["hour"], dt["minute"], dt["second"]]
	)


func update_text():
	var game_id = game_file.get_meta("folder_name")
	var text = game_file.get_value("game", "desc")

	text += ("\n\nPlayed: %.3f s" % GameManager.get_played_time(game_id))

	var last_played = GameManager.get_last_played(game_id)
	if last_played != null:
		text += "\nLast played: %s" % format_date(last_played)

	var highscore_dict = GameManager.get_highscore(game_id)
	if highscore_dict["score"] != null:
		if "_time" in highscore_dict:
			text += (
				"\nHighscore: %s (%s)"
				% [highscore_dict["score"], format_date(highscore_dict["_time"])]
			)
		else:
			text += "\nHighscore: %s" % highscore_dict["score"]

	# update the highscore displayed in $VBoxContainer/RichTextLabel
	$VBoxContainer/RichTextLabel.bbcode_text = text


func _on_loadbutton_pressed():
	if GameManager.load_game(game_file) != OK:
		disable()
