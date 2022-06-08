class_name SortItPedestal
extends StaticBody

signal box_held(index, box_number)
signal box_dropped(index, box_number)

export(float) var hold_strength = 1300
export(float) var attract_strength = 800
export(float) var attracted_distance = 0.2
export(Material) var particle_wrong_material
export(Material) var particle_right_material

export(float) var p_gain = 0.8
export(float) var i_gain = 0.004
export(float) var d_gain = 2.0

var player: SortItPlayer
var box

var _current_attracting_box
var _current_attract_total_error = Vector3.ZERO
var _current_attract_last_error = Vector3.ZERO

onready var index = int(name)
onready var _pedestal_group = get_parent()
onready var _box_anchor: Spatial = $BoxAnchor
onready var _particels: Particles = $Particles


func set_color(color: Color):
	var mesh = $Mesh.mesh
	var material: SpatialMaterial = mesh.surface_get_material(2).duplicate()  # Get accent material
	material.albedo_color = color
	$Mesh.mesh.surface_set_material(2, material)


func set_correct(is_correct: bool):
	if is_correct:
		_particels.draw_pass_1.surface_set_material(0, particle_right_material)
	else:
		_particels.draw_pass_1.surface_set_material(0, particle_wrong_material)


func _ready():
	var particle_size = _particels.draw_pass_1.size
	_particels.draw_pass_1 = QuadMesh.new()
	_particels.draw_pass_1.size = particle_size


func _attract_box(to_attract_box: Box, strength: float, delta: float):
	# Reset PID Controller every new box
	if to_attract_box != _current_attracting_box:
		_current_attracting_box = to_attract_box
		_current_attract_total_error = Vector3.ZERO
		_current_attract_last_error = Vector3.ZERO
	var anchor = _box_anchor.global_transform.origin
	var box_pos = to_attract_box.global_transform.origin
	# Calculate force to apply with PID controller
	var proportional_error = anchor - box_pos
	var integral_error = _current_attract_total_error + proportional_error
	var derivatve_error = proportional_error - _current_attract_last_error
	var action_vector = (
		p_gain * proportional_error
		+ i_gain * integral_error
		+ d_gain * derivatve_error
	)
	# Apply force
	var strength_vector = Vector3(strength, strength, strength)
	to_attract_box.add_force(action_vector * strength_vector * delta, Vector3(0, 0, 0))
	_current_attract_last_error = proportional_error
	_current_attract_total_error += proportional_error


func _physics_process(delta):
	if box != null:
		_attract_box(box, hold_strength, delta)
		$Particles.emitting = true
		return
	$Particles.emitting = false
	for body in $Area.get_overlapping_bodies():
		# Ensure that the box is not currently grabbed by the player
		if not player.left_box == null:
			var player_box = player.left_box as Box
			if player_box.get_instance_id() == body.get_instance_id():
				return
		if not player.right_box == null:
			var player_box = player.right_box as Box
			if player_box.get_instance_id() == body.get_instance_id():
				return

		_attract_box(body, attract_strength, delta)
		# Check if the box is close enught to be "held". Only one box can be held at once
		var distance = body.global_transform.origin.distance_to(_box_anchor.global_transform.origin)
		if (distance <= attracted_distance) == true:
			box = body as Box
			box.stop_despawn()
			box.add_collision_exception_with(player)
			emit_signal("box_held", index, box.number)


# Stop holding box, if it leaves the area
func _on_Area_body_exited(body: Box):
	if box == null:
		return
	# Reset PID Controller if box leaves the area
	if _current_attracting_box != null:
		if box.get_instance_id() == _current_attracting_box.get_instance_id():
			_current_attracting_box = null
	if box.get_instance_id() == body.get_instance_id():
		box.reset_despawn()
		box.remove_collision_exception_with(player)
		emit_signal("box_dropped", index, box.number)
		box = null
