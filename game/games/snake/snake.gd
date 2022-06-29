extends ColorRect

onready var _label_score = $CC/VC/MC/VC/LabelScore
onready var _label_highscore = $CC/VC/MC/VC/LabelHighScore


func _ready():
	var highscore_dict = GameManager.get_highscore()
	if highscore_dict.has("score"):
		var highscore = highscore_dict["score"]
		if highscore != null:
			set_highscore(highscore)


func set_score(score: int):
	_label_score.text = "Score: %s" % score


func set_highscore(highscore: int):
	_label_highscore.text = "Highscore: %s" % highscore
