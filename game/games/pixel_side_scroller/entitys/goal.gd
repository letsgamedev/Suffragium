extends Area2D

onready var main = get_tree().current_scene


func _on_Goal_body_entered(_body):
	main.goal_reached()
