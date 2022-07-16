extends Node2D

var SCENE = preload("res://games/suffro_mania/enemies/Enemy_explosion.tscn")


var rng = RandomNumberGenerator.new()

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	GameManager.restart_game()


func boom() -> void:
	rng.randomize()
	
	var instance = SCENE.instance()
	get_parent().add_child(instance)
	instance.position = position + Vector2(rng.randi_range(-50,50),rng.randi_range(-50,50))
	
	get_parent().player.screen_shake(20)
