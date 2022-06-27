extends ColorRect

var _game_config: ConfigFile = null
var _playtime: float = 0
var _last_played: int = 0

onready var _label_title := $MC/VC/HC/VC/MC/LabelTitle
onready var _label_description := $MC/VC/SC/MC/LabelDescription
onready var _texture_icon_rect := $MC/VC/HC/TextureRectIcon
onready var _label_playtime := $MC/VC/HC/VC/HC/LabelPlaytimeNumber
onready var _label_playtime_unit := $MC/VC/HC/VC/HC/LabelPlaytimeUnit

onready var _popup_label_title := $PopupDialogInfo/VC/PC/MC/HC/MC/VC/MC/LabelTitle
onready var _popup_label_description := $PopupDialogInfo/VC/PC2/MC/HC/SC/MC/VC/LabelDescription
onready var _popup_icon_rect := $PopupDialogInfo/VC/PC/MC/HC/TextureRectIcon
onready var _popup_label_author := $PopupDialogInfo/VC/PC2/MC/HC/VC/LabelAuthor
onready var _popup_label_version := $PopupDialogInfo/VC/PC2/MC/HC/VC/LabelVersion
onready var _popup_label_playtime := $PopupDialogInfo/VC/PC/MC/HC/MC/VC/HC/LabelPlaytimeNumber
onready var _popup_label_playtime_unit := $PopupDialogInfo/VC/PC/MC/HC/MC/VC/HC/LabelPlaytimeUnit
onready var _popup_label_highscore := $PopupDialogInfo/VC/PC/MC/HC/VC/LabelHighscore


func setup(game_config: ConfigFile):
	_game_config = game_config

	var game_folder_path = game_config.get_meta("folder_path")
	_playtime = GameManager.get_playtime(game_folder_path)
	_last_played = GameManager.get_time_last_played(game_folder_path)
	var highscore_dict = GameManager.get_highscore(game_folder_path)
	var highscore = "-"
	if highscore_dict.has("score"):
		highscore = str(highscore_dict["score"])
	_popup_label_highscore.text = highscore

	var game_name = game_config.get_value("game", "name")
	var game_description = game_config.get_value("game", "desc")

	var playtime_dict = _format_playtime(_playtime)
	var playtime_number = playtime_dict["number"]
	var playtime_unit = playtime_dict["unit"]

	_label_title.text = game_name
	_label_description.text = game_description
	_label_playtime.text = playtime_number
	_label_playtime_unit.text = playtime_unit

	_popup_label_title.text = game_name
	_popup_label_description.text = game_description
	_popup_label_author.text = game_config.get_value("game", "creator")
	_popup_label_version.text = game_config.get_value("game", "version")
	_popup_label_playtime.text = playtime_number
	_popup_label_playtime_unit.text = playtime_unit

	var file_name_icon = game_config.get_value("game", "icon")
	var icon_path = "%s/%s" % [game_folder_path, file_name_icon]
	var icon: Texture = load(icon_path)
	if icon != null:
		_texture_icon_rect.texture = icon
		_popup_icon_rect.texture = icon


func get_title() -> String:
	return _game_config.get_value("game", "name")


func get_playtime() -> float:
	return _playtime


func get_last_played() -> int:
	return _last_played


func _format_playtime(playtime) -> Dictionary:
	var playtime_dict = {}
	if playtime == 0:
		playtime_dict["number"] = "-"
		playtime_dict["unit"] = ""
	elif playtime < 90:
		playtime_dict["number"] = "1"
		playtime_dict["unit"] = "T_0009"
	elif playtime < 3570:
		playtime_dict["number"] = str(round(playtime / 60.0))
		playtime_dict["unit"] = "T_000A"
	elif playtime < 5400:
		playtime_dict["number"] = "1"
		playtime_dict["unit"] = "T_000B"
	else:
		playtime_dict["number"] = str(round(playtime / 3600.0))
		playtime_dict["unit"] = "T_000C"
	return playtime_dict


func _on_ButtonInfo_pressed():
	$PopupDialogInfo.popup_centered()


func _on_ButtonPlay_pressed():
	GameManager.load_game(_game_config)


func _on_ButtonClosePopup_pressed():
	$PopupDialogInfo.hide()
