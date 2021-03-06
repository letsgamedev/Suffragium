tool
extends Area2D

export(Vector2) var trigger_size = Vector2(10, 10) setget _set_trigger_size
var _triggered: bool = false
onready var _main = get_tree().current_scene


func _set_trigger_size(new_size: Vector2):
	trigger_size = new_size
	$CollisionShape2D.shape.extents = new_size


func _on_Goal_body_entered(body):
	if _triggered:
		return
	if body is KinematicBody2D and body.is_in_group("Player"):
		body.disable()
		_triggered = true
		_main.goal_reached()
