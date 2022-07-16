extends KinematicBody2D

var DAMAGE = 1

var hp = 0

var hitstun = 0
var hitstun_max = 40

var score_scene = preload("res://games/suffro_mania/Score.tscn")
var SCORE = 100

var explosion_scene = preload("res://games/suffro_mania/enemies/Enemy_explosion.tscn")
var boss_scene = preload("res://games/suffro_mania/enemies/Boss_explosion.tscn")

var powerup_scene = preload("res://games/suffro_mania/Powerup.tscn")

var rdm = RandomNumberGenerator.new()

func hit(dmg) -> void:	
	hitstun = hitstun_max
	
	hp -= dmg
	
	var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
	SFX.play("damageE")
	get_parent().add_child(SFX)
	
	if hp <= 0:
		if not is_in_group("BOSS"):
			var instance = score_scene.instance()
			instance.score = SCORE
			instance.get_child(0).rect_position = position
			get_parent().add_child(instance)
			
			instance = explosion_scene.instance()
			get_parent().add_child(instance)
			instance.position = position
			
			rdm.randomize()
			if rdm.randi_range(0,15) == 1:
				instance = powerup_scene.instance()
				instance.type = "ENERGY"
				get_parent().add_child(instance)
				instance.position = position
			
			get_parent().get_parent().player.screen_shake(1.5)
		
		else:
			var instance = score_scene.instance()
			instance.score = SCORE
			instance.get_child(0).rect_position = position
			get_parent().add_child(instance)
			
			instance = boss_scene.instance()
			get_parent().add_child(instance)
			instance.position = position
		
		queue_free()
		


func _on_VisibilityNotifier2D_viewport_entered(viewport: Viewport) -> void:
	if not is_in_group("BOSS"):
		set_physics_process(true)



func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void:
	if not is_in_group("BOSS"):
		set_physics_process(false)

