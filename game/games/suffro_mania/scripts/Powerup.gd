extends Node2D

export (String, "SCORE", "GRAVITY", "ENERGY") var type = "SCORE" 

var score_scene = preload("res://games/suffro_mania/Score.tscn")
var SCORE = 5000

func _ready() -> void:
	if type == "GRAVITY":
		$Sprite.frame = 1
	elif type == "ENERGY":
		$Sprite.frame = 2

func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("PLAYER"):
		
		var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("powerup")
		get_parent().add_child(SFX)
		
		match type:
			"SCORE":
				var instance = score_scene.instance()
				instance.score = SCORE
				instance.get_child(0).rect_position = position
				get_parent().add_child(instance)
				
			"GRAVITY":
				body.can_flip = true
				
				var instance = score_scene.instance()
				instance.score = "PRESS W"
				instance.get_child(0).rect_position = position
				get_parent().add_child(instance)
				
			"ENERGY":
				body.hp += 3
				
				if body.hp > body.max_hp:
					body.hp = body.max_hp
		
				get_parent().get_parent().update_health()
				
		queue_free()
