extends Node2D

const SPEED = 20

var score = 100

var t = 0

const colors = ["#ffffff", "#9400D3", "#4B0082", "#0000FF", "#00FF00", "#FFFF00", "#FF7F00", "#FF0000"]

onready var label = $Label

func _ready() -> void:
	label.text = str(score)
	if typeof(score) == TYPE_INT:
		get_parent().get_parent().score += score
	

func _process(delta: float) -> void:
	t += 1
	position.y -= SPEED * delta
	position.x = sin(t * 0.1) * 3
	
	self.modulate = colors[t % colors.size()]
	
	if t > 120:
		queue_free()
