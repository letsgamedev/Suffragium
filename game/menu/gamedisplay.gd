extends MarginContainer

var game_file : ConfigFile
signal pressed(game_file)


func setup(game_cfg:ConfigFile):
	game_file = game_cfg
	
	$VBoxContainer/Label.text = game_cfg.get_value("game", "name")
	$VBoxContainer/RichTextLabel.bbcode_text = game_cfg.get_value("game", "desc")
	
	var icon : Texture = load(str(game_cfg.get_meta("folder_path"), game_cfg.get_value("game", "icon")))
	if icon == null: icon = load("res://icon.png")
	$VBoxContainer/TextureRect.texture = icon
	
	#setup of info Dialog
	##setup buttons
	$InfoButton.connect("pressed", $InfoDialog, "popup_centered_minsize", [Vector2(500, 250)])
	var loadbtn = $InfoDialog.add_button("load")
	loadbtn.connect("pressed", $InfoDialog, "hide")
	loadbtn.connect("pressed", self, "_on_loadbutton_pressed")
	##setup text
	$InfoDialog/Container/Label.text = game_cfg.get_value("game", "name")
	$InfoDialog/Container/TextureRect.texture = icon
	$InfoDialog/Container/descCont/desclab.bbcode_text = game_cfg.get_value("game", "desc")
	var text = ""
	text += "Author: " + game_cfg.get_value("game", "creator") + "\n"
	text += "Version: " + game_cfg.get_value("game", "version") + "\n"
	$InfoDialog/Container/descCont/Statslab.text = text
	


func _on_loadbutton_pressed():
	emit_signal("pressed", game_file)
