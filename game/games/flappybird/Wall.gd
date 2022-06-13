extends StaticBody2D

const MOVEMENT_VECTOR = Vector2(-120, 0)


func _ready():
	pass


func _physics_process(delta):
	position += delta * MOVEMENT_VECTOR
