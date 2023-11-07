@tool
extends Area2D

@export var trigger_size: Vector2 = Vector2(20, 20):
	set = _set_trigger_size
@onready var _main = get_tree().current_scene


func _set_trigger_size(new_size: Vector2):
	trigger_size = new_size
	$CollisionShape2D.shape.size = new_size


func _on_HelpTrigger_body_entered(body):
	if body is CharacterBody2D and body.is_in_group("Player"):
		_main.kill_player()
