class_name SortItPedestal
extends StaticBody3D

signal box_held(index, box_number)
signal box_dropped(index, box_number)

@export var hold_strength: float = 1300
@export var attract_strength: float = 800
@export var attracted_distance: float = 0.2
@export var particle_wrong_material: Material
@export var particle_right_material: Material

@export var p_gain: float = 0.8
@export var i_gain: float = 0.004
@export var d_gain: float = 2.0

var box

var _current_attracting_box
var _current_attract_total_error = Vector3.ZERO
var _current_attract_last_error = Vector3.ZERO
var _players = []

@onready var index = int(name)
@onready var _box_anchor: Node3D = $BoxAnchor
@onready var _particels: Particles = $Particles
@onready var _mesh_instance = $Mesh


func set_color(color: Color):
	var mesh = _mesh_instance.mesh
	var material: StandardMaterial3D = mesh.surface_get_material(2).duplicate()  # Get accent material
	material.albedo_color = color
	_mesh_instance.mesh.surface_set_material(2, material)


func set_correct(is_correct: bool):
	if is_correct:
		_particels.draw_pass_1.surface_set_material(0, particle_right_material)
	else:
		_particels.draw_pass_1.surface_set_material(0, particle_wrong_material)


func set_players(players: Array):
	_players = players


func _ready():
	var particle_size = _particels.draw_pass_1.size
	_particels.draw_pass_1 = QuadMesh.new()
	_particels.draw_pass_1.size = particle_size


func _attract_box(to_attract_box: SortItBox, strength: float, delta: float):
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
	to_attract_box.apply_force(Vector3(0, 0, 0), action_vector * strength_vector * delta)
	_current_attract_last_error = proportional_error
	_current_attract_total_error += proportional_error


func _physics_process(delta):
	if box != null:
		_attract_box(box, hold_strength, delta)
		$Particles.emitting = true
		return
	$Particles.emitting = false
	for body in $Area3D.get_overlapping_bodies():
		# Ensure that the box is not currently grabbed by a player
		var body_instance_id = body.get_instance_id()
		for player in _players:
			if not player.left_box == null:
				var player_box = player.left_box as SortItBox
				if player_box.get_instance_id() == body_instance_id:
					return
			if not player.right_box == null:
				var player_box = player.right_box as SortItBox
				if player_box.get_instance_id() == body_instance_id:
					return

		_attract_box(body, attract_strength, delta)
		# Check if the box is close enught to be "held". Only one box can be held at once
		var distance = body.global_transform.origin.distance_to(_box_anchor.global_transform.origin)
		if (distance <= attracted_distance) == true:
			box = body as SortItBox
			box.stop_despawn()
			# Stop all players from colliding with the box to make griefing harder
			for player in _players:
				box.add_collision_exception_with(player)
			# Emit signal to recalculate the players score and mark pedestal as occupied
			emit_signal("box_held", index, box.number)


# Stop holding box, if it leaves the area
func _on_Area_body_exited(body: SortItBox):
	if box == null:
		return
	# Reset PID Controller if box leaves the area
	if _current_attracting_box != null:
		if box.get_instance_id() == _current_attracting_box.get_instance_id():
			_current_attracting_box = null
	if box.get_instance_id() == body.get_instance_id():
		box.reset_despawn()
		# Activate collision with players when the box is dropped
		for player in _players:
			box.remove_collision_exception_with(player)
		# Emit signal to recalculate the player score am mark pedestal as empty
		emit_signal("box_dropped", index, box.number)
		box = null
