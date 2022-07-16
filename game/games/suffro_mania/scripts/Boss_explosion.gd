extends Node2D

const AMOUNT := 10

var SCENE = preload("res://games/suffro_mania/enemies/Enemy_explosion.tscn")

var rng = RandomNumberGenerator.new()

func _ready() -> void:
	get_parent().get_parent().get_node("BackgroundMusic").stop()
	
	rng.randomize()
	
	var instance = SCENE.instance()
	add_child(instance)
	instance.position = position 
	
	$AnimationPlayer.play("explode")
	

func boom() -> void:
	var instance = SCENE.instance()
	get_parent().add_child(instance)
	instance.position = position + Vector2(rng.randi_range(-200,200),rng.randi_range(-200,200))
	
	get_parent().get_parent().player.screen_shake(20)


func play() -> void:
	$AudioStreamPlayer.play()



func _on_AudioStreamPlayer_finished() -> void:
	var anim : AnimationPlayer = get_parent().get_parent().get_node("UI/Fader/Anim")
	if not anim.is_playing():
		anim.play("fadeIn")
		print("PLAY")
		
	yield(anim, "animation_finished")
	get_parent().get_parent().get_node("UI/EndScreen").visible = true
	queue_free()
