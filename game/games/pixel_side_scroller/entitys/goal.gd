@tool
extends Area2D

@export var trigger_size: Vector2 = Vector2(10, 10): set = _set_trigger_size
var _triggered: bool = false
@onready var _main = get_tree().current_scene


func _set_trigger_size(new_size: Vector2):
	trigger_size = new_size
	$CollisionShape2D.shape.size = new_size


func _on_Goal_body_entered(body):
	if _triggered:
		return
	if body is CharacterBody2D and body.is_in_group("Player"):
		body.disable()
		_triggered = true
		_main.goal_reached()
