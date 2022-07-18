extends PanelContainer

var _game_config: ConfigFile = null
var _playtime: float = 0
var _last_played = -1

onready var _label_title := $Card/TitleSection/VC/LabelTitle
onready var _label_description := $Card/SC/MC/Description
onready var _texture_icon_rect := $Card/TitleSection/icon
onready var _label_playtime := $Card/TitleSection/VC/HC/LabelPlaytimeNumber
onready var _label_playtime_unit := $Card/TitleSection/VC/HC/LabelPlaytimeUnit

onready var _popup_label_title := $PopupDialogInfo/VC/TitleSection/HC/Title/LabelTitle
onready var _popup_label_description := $PopupDialogInfo/VC/InfoSection/HC/Description
onready var _popup_icon_rect := $PopupDialogInfo/VC/TitleSection/HC/TextureRectIcon
onready var _popup_label_author := $PopupDialogInfo/VC/InfoSection/HC/VC/LabelAuthor
onready var _popup_label_version := $PopupDialogInfo/VC/InfoSection/HC/VC/LabelVersion
onready var _popup_playtime := $PopupDialogInfo/VC/TitleSection/HC/Title/HC/LabelPlaytimeNumber
onready var _popup_playtime_2 := $PopupDialogInfo/VC/TitleSection/HC/Title/HC/LabelPlaytimeNumber2
onready var _popup_playtime_unit := $PopupDialogInfo/VC/TitleSection/HC/Title/HC/LabelPlaytimeUnit
onready var _popup_playtime_unit_2 := $PopupDialogInfo/VC/TitleSection/HC/Title/HC/PlaytimeUnit2
onready var _popup_label_highscore := $PopupDialogInfo/VC/TitleSection/HC/HighScore/LabelHighscore


func setup(game_config: ConfigFile):
	_game_config = game_config
	var game_id = game_config.get_meta("folder_name")

	var game_name = game_config.get_value("game", "name")
	var game_description = game_config.get_value("game", "desc")

	_playtime = GameManager.get_playtime(game_id)
	_last_played = GameManager.get_time_last_played(game_id)
	var playtime_dict = _format_playtime(_playtime)
	var playtime_number = playtime_dict["number"]
	var playtime_unit = playtime_dict["unit"]

	if playtime_dict.has("another_number"):
		_popup_playtime_2.visible = true
		_popup_playtime_2.text = playtime_dict["another_number"]
	if playtime_dict.has("another_unit"):
		_popup_playtime_unit_2.visible = true
		_popup_playtime_unit_2.text = playtime_dict["another_unit"]

	var highscore_dict = GameManager.get_highscore(game_id)
	if highscore_dict.has("score"):
		_popup_label_highscore.text = str(highscore_dict["score"])
	else:
		$PopupDialogInfo/VC/TitleSection/HC/HighScore.visible = false

	_label_title.text = game_name
	_label_description.text = game_description
	_label_playtime.text = playtime_number
	_label_playtime_unit.text = playtime_unit

	_popup_label_title.text = game_name
	_popup_label_description.text = game_description
	_popup_label_author.text = game_config.get_value("game", "creator")
	_popup_label_version.text = game_config.get_value("game", "version")
	_popup_playtime.text = playtime_number
	_popup_playtime_unit.text = playtime_unit

	var icon_file_name = game_config.get_value("game", "icon")
	var icon_path = GameManager.make_game_file_path(game_id, icon_file_name)
	var icon: Texture = load(icon_path)
	if icon != null:
		_texture_icon_rect.texture = icon
		_popup_icon_rect.texture = icon


func get_title() -> String:
	return _game_config.get_value("game", "name")


func get_playtime() -> float:
	return _playtime


func get_last_played():
	return _last_played


func _format_playtime(playtime: float) -> Dictionary:
	var playtime_dict = {}
	if playtime == 0:
		playtime_dict["number"] = "-"
		playtime_dict["unit"] = ""
	elif playtime < 1.5:
		playtime_dict["number"] = "1"
		playtime_dict["unit"] = "T_SECOND"
	elif playtime < 59.5:
		playtime_dict["number"] = str(round(playtime))
		playtime_dict["unit"] = "T_SECONDS"
	elif playtime < 90:
		playtime_dict["number"] = "1"
		playtime_dict["unit"] = "T_MINUTE"
	elif playtime < 3570:
		playtime_dict["number"] = str(round(playtime / 60.0))
		playtime_dict["unit"] = "T_MINUTES"
	elif playtime < 5400:
		playtime_dict["number"] = "1"
		playtime_dict["unit"] = "T_HOUR"
	else:
		playtime_dict["number"] = str(round(playtime / 3600.0))
		playtime_dict["unit"] = "T_HOURS"
	if playtime >= 3630 and playtime < 34200:
		var time_rest_after_hours = fmod(playtime, 3600.0)
		var formatted_rest = _format_playtime(time_rest_after_hours)
		playtime_dict["another_number"] = formatted_rest["number"]
		playtime_dict["another_unit"] = formatted_rest["unit"]
	return playtime_dict


func _on_ButtonInfo_pressed():
	$PopupDialogInfo.popup_centered($PopupDialogInfo/VC.rect_size)


func _on_ButtonPlay_pressed():
	GameManager.load_game(_game_config)


func _on_ButtonClosePopup_pressed():
	$PopupDialogInfo.hide()
