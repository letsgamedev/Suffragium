extends Control


func _ready() -> void:
	visible = false
	yield(get_tree().create_timer(1), "timeout")


func _process(delta: float) -> void:
	if visible and not get_tree().paused:
		get_tree().paused = true
		
		var root = get_parent().get_parent()
		
		
		root.calc_score()
		
		$Score.text = str(root.score)
		$Hp.text = str(root.healthScore)
		$Time.text = str(root.timeScore)
		
		prints(root.score, root.healthScore, root.timeScore)
		
		$Total.text = str(root.finalScore)
		
	
	if Input.is_action_just_pressed("ui_accept") and visible:
		GameManager.end_game(str("Your Highscore: ", $Total.text), int($Total.text))
	
	if Input.is_action_just_pressed("K") and visible:
		GameManager.restart_game()
		
	if Input.is_action_just_pressed("W") and visible:
		get_parent().get_node("Credits").visible = !get_parent().get_node("Credits").visible

		
