extends StaticBody2D

var hp = 3


var explosion_scene = preload("res://games/suffro_mania/enemies/Enemy_explosion.tscn")


func hitted() -> void:
	hp -= 1

	
	var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
	SFX.play("damageE")
	get_parent().add_child(SFX)
	
	if hp <= 0:
		var instance = explosion_scene.instance()
		get_parent().add_child(instance)
		instance.position = position
		queue_free()
	

func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player_projectiles"):
		hitted()
