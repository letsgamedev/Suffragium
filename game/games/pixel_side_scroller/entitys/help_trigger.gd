tool
extends Area2D

export(int) var feature = PixelSideScrollerUtils.Features.MOVE
export(Vector2) var trigger_size = Vector2(20, 20) setget _set_trigger_size
var _triggered: bool = false
onready var _main = get_tree().current_scene


func _set_trigger_size(new_size: Vector2):
	trigger_size = new_size
	$CollisionShape2D.shape.extents = new_size


func _on_HelpTrigger_body_entered(body):
	if _triggered:
		return
	if body is KinematicBody2D and body.is_in_group("Player"):
		_triggered = true
		_main.ui.help_box.display(feature)
