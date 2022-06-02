extends KinematicBody

var color: Color = Color(0, 0, 0, 1) setget set_color, get_color
var speed: float = 5.0
onready var main = get_tree().current_scene
onready var input_handler = $InputHandler


func get_color():
	return $CSGCylinder.material.albedo_color


func set_color(new_color: Color):
	$CSGCylinder.material = $CSGCylinder.material.duplicate()
	$CSGCylinder.material.albedo_color = new_color


func _process(_delta):
	var move_direction: Vector3 = Vector3(
		input_handler.move_direction.x, 0, input_handler.move_direction.y
	)
	if move_direction.length() > 1:
		move_direction = move_direction.normalized()
	var move_velocity: Vector3 = move_direction * speed
# warning-ignore:return_value_discarded
	move_and_slide(move_velocity, Vector3(0, 1, 0))

	if main.network.is_own_pawn(self):
		rpc_unreliable("update_translation", translation)


#		rset_unreliable("translation", translation)


puppet func update_translation(_translation: Vector3):
	translation = _translation
