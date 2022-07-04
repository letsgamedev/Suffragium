extends ColorRect

onready var _label_score = $CC/VC/MC/VC/LabelScore
onready var _label_highscore = $CC/VC/MC/VC/LabelHighScore


func _ready():
	var highscore_dict = GameManager.get_highscore()
	if highscore_dict.has("score"):
		var highscore = highscore_dict["score"]
		if highscore != null:
			display_highscore(highscore)


func display_score(score: int):
	_label_score.text = "Score: %s" % score


func display_highscore(highscore: int):
	_label_highscore.text = "Highscore: %s" % highscore
