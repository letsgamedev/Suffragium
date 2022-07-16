extends Node2D

const AMOUNT := 30

var SCENE = preload("res://games/suffro_mania/enemies/Enemy_explosion_particle.tscn")

func _ready() -> void:
	for i in AMOUNT:
		var instance = SCENE.instance()
		add_child(instance)
		instance.position = position
		
	var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
	SFX.play("explodeE")
	get_parent().add_child(SFX)


func _process(delta: float) -> void:
	if get_child_count() <= 0:
		queue_free()
	
