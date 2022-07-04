extends ColorRect

var _color_selection = preload("res://games/snake/snake_color_selection.tscn")

onready var _label_score = $CC/VC/MC/VC/LabelScore
onready var _label_highscore = $CC/VC/MC/VC/LabelHighScore


func _ready():
	_show_color_selection_dialog()
	display_score(0)
	_load_and_show_highscore()


func display_score(score: int):
	_label_score.text = "%s: %s" % [TranslationServer.translate("T_SCORE"), score]


func display_highscore(highscore: int):
	_label_highscore.text = "%s: %s" % [TranslationServer.translate("T_HIGHSCORE"), highscore]


func set_color_scheme(color_scheme: int):
	var canvas = $CC/VC/CanvasBackground/Canvas
	canvas.color_scheme = color_scheme
	canvas.redraw()


func _show_color_selection_dialog():
	var dialog = _color_selection.instance()
	get_tree().get_root().add_child(dialog)
	dialog.set_main(self)


func _load_and_show_highscore():
	var highscore_dict = GameManager.get_highscore()
	if highscore_dict.has("score"):
		var highscore = highscore_dict["score"]
		if highscore != null:
			display_highscore(highscore)
