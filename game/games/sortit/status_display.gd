extends VBoxContainer

const STATUS_TEXT = "%d points"


func display_score(score: int):
	$HBoxContainer/StatusLabel.text = STATUS_TEXT % score
