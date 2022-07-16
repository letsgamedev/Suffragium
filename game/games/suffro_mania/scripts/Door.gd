extends StaticBody2D

var open := false

export (bool) var onshot = false
var blocked = false

func _on_Opener_area_entered(area: Area2D) -> void:
	if not blocked:
		if area.get_parent().is_in_group("player_projectiles"):
			$AnimationPlayer.play("open")
			open = true
			$Timer.start()
			
			var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
			SFX.play("open")
			get_parent().add_child(SFX)
			
			SFX = load("res://games/suffro_mania/SFX.tscn").instance()
			SFX.play("openBeep")
			get_parent().add_child(SFX)
	else:
		var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("bing")
		get_parent().add_child(SFX)

func _on_Timer_timeout() -> void:
	var canClose = true
	for body in $StuckChecker.get_overlapping_bodies():
		if body.is_in_group("PLAYER"):
			canClose = false
			$Timer.wait_time = 0.5
			$Timer.start()
			
	if canClose:
		$AnimationPlayer.play("close")
		$Timer.stop()
		
		var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("close")
		get_parent().add_child(SFX)
		
		SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("closeBeep")
		get_parent().add_child(SFX)
		


func _on_oneshot_body_entered(body: Node) -> void:
	if body.is_in_group("PLAYER") and onshot and not blocked:
		blocked = true
		$Timer.stop()
		$AnimationPlayer.play("close")
		
		var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("close")
		get_parent().add_child(SFX)
		
		SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("closeBeep")
		get_parent().add_child(SFX)
		
		get_parent().get_node("BackgroundMusic").stop()
		
