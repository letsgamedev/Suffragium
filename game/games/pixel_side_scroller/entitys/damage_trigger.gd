tool
extends Area2D

export(Vector2) var trigger_size = Vector2(20, 20) setget _set_trigger_size
onready var _main = get_tree().current_scene


func _set_trigger_size(new_size: Vector2):
	trigger_size = new_size
	$CollisionShape2D.shape.extents = new_size


func _on_HelpTrigger_body_entered(body):
	if body is KinematicBody2D and body.is_in_group("Player"):
		_main.kill_player()
