class_name GameDisplay

extends MarginContainer

signal pressed(game_file)

var game_file: ConfigFile
var _load_btn_main: Button
var _load_btn_dialog: Button

func setup(game_cfg: ConfigFile):
	game_file = game_cfg
	_load_btn_main = $VBoxContainer/loadbutton

	$VBoxContainer/Label.text = game_cfg.get_value("game", "name")
	$VBoxContainer/RichTextLabel.bbcode_text = game_cfg.get_value("game", "desc")

	var icon: Texture = load(
		str(game_cfg.get_meta("folder_path"), game_cfg.get_value("game", "icon"))
	)
	if icon == null:
		icon = load("res://icon.png")
	$VBoxContainer/TextureRect.texture = icon

	#setup of info Dialog
	##setup buttons
	_handle_error($InfoButton.connect("pressed", $InfoDialog, "popup_centered_minsize", [Vector2(500, 250)]))
	_load_btn_dialog = $InfoDialog.add_button("load")
	_handle_error(_load_btn_dialog.connect("pressed", $InfoDialog, "hide"))
	_handle_error(_load_btn_dialog.connect("pressed", self, "_on_loadbutton_pressed"))
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

# TODO: Maybe put this somewhere more central for reuse or smth
func _handle_error(err):
	if err != OK:
		prints("Error", err)
		return

func _on_loadbutton_pressed():
	emit_signal("pressed", game_file, self)
