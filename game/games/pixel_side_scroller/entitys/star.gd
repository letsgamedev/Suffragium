extends Area2D

onready var _main = get_tree().current_scene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_main.count_star()


func _on_Star_body_entered(body: Node) -> void:
	if not self.visible:
		return
	if body is KinematicBody2D and body.is_in_group("Player"):
		self.visible = false
		_main.collected_star()
