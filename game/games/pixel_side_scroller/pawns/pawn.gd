extends CharacterBody2D

@onready var input = $Input
@onready var movement = $Movement
@onready var _main = get_tree().current_scene


func _physics_process(delta):
	if _main.map_manager.out_of_bound(self):
		_main.kill_player()
		return
	movement.do(delta)


func disable():
	$CollisionShape2D.set_deferred("disabled", true)


func enable():
	$CollisionShape2D.disabled = false
