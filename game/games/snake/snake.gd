extends ColorRect

var _res_color_selection = preload("res://games/snake/snake_color_selection.tscn")
var _res_canvas = preload("res://games/snake/canvas.tscn")

var _selected_color_scheme: int = 0

@onready var _label_score = $CC/VC/MC/VC/LabelScore
@onready var _label_highscore = $CC/VC/MC/VC/LabelHighScore


func _ready():
	_show_color_selection_dialog()
	display_score(0)
	_load_and_show_highscore()


func display_score(score: int):
	_label_score.text = "%s: %s" % [TranslationServer.translate("T_SCORE"), score]


func display_highscore(highscore: int):
	_label_highscore.text = "%s: %s" % [TranslationServer.translate("T_HIGHSCORE"), highscore]


func set_color_scheme(color_scheme: int):
	_selected_color_scheme = color_scheme
	_start_game()


func _start_game():
	var canvas_bg = $CC/VC/CanvasBackground
	var canvas = _res_canvas.instantiate()
	canvas_bg.add_child(canvas)
	canvas.color_scheme = _selected_color_scheme
	canvas.redraw()


func _show_color_selection_dialog():
	var dialog = _res_color_selection.instantiate()
	add_child(dialog)
	dialog.set_main(self)


func _load_and_show_highscore():
	var highscore_dict = GameManager.get_highscore()
	if highscore_dict.has("score"):
		var highscore = highscore_dict["score"]
		if highscore != null:
			display_highscore(highscore)
