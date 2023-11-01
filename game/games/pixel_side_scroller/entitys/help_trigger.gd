@tool
extends Area2D

@export var feature: int = PixelSideScrollerUtils.Features.MOVE
@export var trigger_size: Vector2 = Vector2(20, 20): set = _set_trigger_size
var _triggered: bool = false
@onready var _main = get_tree().current_scene


func _set_trigger_size(new_size: Vector2):
	trigger_size = new_size
	$CollisionShape2D.shape.size = new_size


func _on_HelpTrigger_body_entered(body):
	if _triggered:
		return
	if body is CharacterBody2D and body.is_in_group("Player"):
		_triggered = true
		_main.ui.help_box.display(feature)
