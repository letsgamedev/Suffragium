class_name SortItPlayer
extends CharacterBody3D

const SQRT2 = sqrt(2)

@export var old_rotational_controls: bool = false
@export var direction_change_speed: float = 4
@export var move_speed: int = 1000
@export var max_speed: float = 5
@export var attract_speed: float = 500
@export var friction: float = 0.7
@export var angular_friction: float = 0.5
@export var max_box_distance: float = 5.0
@export var attracted_distance: float = 2.7
@export var camera_rotate_speed: float = 0.8
@export var pedestal_arrow_display_distance: float = 200
@export var camera_offset: Vector3 = Vector3(-8, 20, 0)
@export var greater_compare_material: Material
@export var normal_compare_material: Material

# Needs to be set by parent class
var player_index:
	get = get_player_index,
	set = set_player_index
var camera: Camera3D
var status_display: Control

var left_magnet_active = false
var right_magnet_active = false

var left_box = null
var right_box = null

var _player_index: int
var _last_direction = Vector3.ZERO
var _velocity = Vector3.ZERO
var _angular_velocity = 0.0
var _pedestal_position: Vector3
@onready var _left_anchor = $LeftMagnet/Anchor
@onready var _right_anchor = $RightMagnet/Anchor
@onready var _players = get_parent()
@onready var _main_body_mesh = $Mesh/MainBody


func set_player_index(new_player_index: int):
	_player_index = new_player_index
	# Grab the correct pedestal position
	_pedestal_position = $"../../Pedestals".get_child(_player_index).global_transform.origin


func get_player_index() -> int:
	return _player_index


func set_color(color: Color):
	var material: StandardMaterial3D = _main_body_mesh.mesh.surface_get_material(0).duplicate()
	material.albedo_color = color
	_main_body_mesh.mesh.surface_set_material(0, material)


func _input(_event):
	var last_left_magnet_active = left_magnet_active
	var last_right_magnet_active = right_magnet_active
	if _players.is_action_just_pressed("left_magnet", _player_index):
		left_magnet_active = !left_magnet_active
	elif _players.is_action_just_pressed("right_magnet", _player_index):
		right_magnet_active = !right_magnet_active

	# Handle dropping off attached boxes, when disabling magnets
	if last_left_magnet_active and not left_magnet_active and left_box != null:
		left_box.linear_velocity = Vector3.ZERO
		left_box.angular_velocity = Vector3.ZERO
		(left_box as SortItBox).reset_despawn()
		left_box.disable_physics(false)
		left_box = null
	if last_right_magnet_active and not right_magnet_active and right_box != null:
		right_box.linear_velocity = Vector3.ZERO
		right_box.angular_velocity = Vector3.ZERO
		(right_box as SortItBox).reset_despawn()
		right_box.disable_physics(false)
		right_box = null

	$LeftMagnet/Particles.emitting = left_magnet_active
	$RightMagnet/Particles.emitting = right_magnet_active


# Gets the angle, that points to the assigned pedestal start (the first pedestal)
func _get_pedestal_direction_angle() -> float:
	# Get plane positions
	var current_pos = global_transform.origin
	var target_pos = _pedestal_position
	current_pos = Vector3(current_pos.x, 0, current_pos.z)
	target_pos = Vector3(target_pos.x, 0, target_pos.z)
	var dir = target_pos - current_pos
	# Calculate angle based on positions
	var pedestal_angle = Vector3.FORWARD.angle_to(dir)
	if dir.x < 0:
		pedestal_angle = (2 * PI) - pedestal_angle
	# Return and incorporate 90deg rotated camera and player rotation
	return pedestal_angle - PI / 2 + rotation.y


func _move_and_rotate(delta):
	# Create direction vector
	var direction = Vector3(0, 0, 0)
	var left_right_strength = _players.get_action_strength("right", _player_index)
	if old_rotational_controls:
		direction.x = left_right_strength
	direction.z = _players.get_action_strength("down", _player_index)
	# Stop faster movement when moving diagonally (only applies to old_rotational_controls)
	if direction.length() > SQRT2:
		direction = direction.normalized()
	# Rotate direction
	var actual_direction: Vector3
	if not old_rotational_controls:
		# Calulate rotation speed
		var rotation_speed_mult = 0.8 if direction == Vector3.ZERO else 1.0
		var rotation_speed = direction_change_speed * rotation_speed_mult
		# Add rotation speed to angluar velocity
		_angular_velocity *= angular_friction
		_angular_velocity += -left_right_strength * rotation_speed
		# Apply angular velocity speed to direction and rotate player
		rotate_y(_angular_velocity * delta)
		actual_direction = direction.rotated(Vector3.UP, rotation.y)
		actual_direction = actual_direction / (abs(left_right_strength) * 0.2 + 1)
		# Update camera rotation smoothly
		var camera_rotation_speed = rotation_speed * camera_rotate_speed * delta
		var camera_angle = lerp_angle(camera.rotation.y, rotation.y - PI / 2, camera_rotation_speed)
		camera.rotation.y = camera_angle
	else:
		var real_direction_change_speed = delta * (direction_change_speed / angular_friction)
		actual_direction = lerp(_last_direction, direction, real_direction_change_speed)
	# Calculate new velocity, calculate friction and apply velocity
	_velocity *= friction
	_velocity = Vector3(
		clamp(actual_direction.x + _velocity.x, -max_speed, max_speed),
		0,
		clamp(actual_direction.z + _velocity.z, -max_speed, max_speed)
	)
	set_velocity(Vector3(-_velocity.z, -0.5, _velocity.x) * delta * move_speed)
	move_and_slide()
	# Look in movement direction (old controls only)
	if direction != Vector3.ZERO and old_rotational_controls:
		rotation.y = atan2(-_velocity.x, -_velocity.z)
	# Point arrow in status display to assigned pedestal, if far away and holding boxes
	if (
		(
			global_transform.origin.distance_squared_to(_pedestal_position)
			> pedestal_arrow_display_distance
		)
		and (left_box != null or right_box != null)
	):
		var pedestal_angle = _get_pedestal_direction_angle()
		status_display.set_pedestal_direction_angle(pedestal_angle)
		status_display.set_display_pointing_arrow(true)
	else:
		status_display.set_display_pointing_arrow(false)
	# Update camera position with correctly rotated offset
	camera.transform.origin = (
		transform.origin + camera_offset.rotated(Vector3.UP, camera.rotation.y + PI / 2)
	)
	_last_direction = actual_direction


func _attract_block(magnet: Node3D, delta: float):
	var area: Area3D = magnet.get_node("Area3D")
	var anchor: Vector3 = magnet.get_node("Anchor").global_transform.origin
	# Get nearest box in area
	var nearest = null
	var min_distance = INF
	for box in area.get_overlapping_bodies():
		var distance = box.global_transform.origin.distance_to(anchor)
		if distance <= max_box_distance and distance < min_distance:
			min_distance = distance
			nearest = box
	if nearest != null:
		# Apply force to move nearest box towards the magnet anchor
		nearest.apply_force(
			(
				(anchor - nearest.global_transform.origin)
				* Vector3(attract_speed, attract_speed * 2, attract_speed)
				* delta
			),
			Vector3(0, 0, 0)
		)
		# If the box is close enougth attach it
		if (min_distance <= attracted_distance) == true:
			(nearest as SortItBox).stop_despawn()
			nearest.disable_physics(true)
			return nearest


func _attract_boxes(delta: float):
	if left_magnet_active and left_box == null:
		left_box = _attract_block($LeftMagnet, delta)
	if right_magnet_active and right_box == null:
		right_box = _attract_block($RightMagnet, delta)


func _stick_box(box: RigidBody3D, anchor: Vector3):
	box.global_transform.origin = anchor  # Keep box at anchor position
	# Keep box rotation in line with the magnet direction (1, 0, 0)
	box.look_at(anchor - (Vector3(-1, 0, 0)).rotated(Vector3.UP, rotation.y), Vector3.UP)


func _stick_boxes():
	if left_box != null:
		_stick_box(left_box, _left_anchor.global_transform.origin)
	if right_box != null:
		_stick_box(right_box, _right_anchor.global_transform.origin)


# Updates the triangle indecators on the player to show what number is bigger
# (important for sorting black boxes)
func _update_comperators():
	if left_box == null or right_box == null:
		_main_body_mesh.set_surface_override_material(2, normal_compare_material)
		_main_body_mesh.set_surface_override_material(1, normal_compare_material)
		return
	if (left_box as SortItBox).number > (right_box as SortItBox).number:
		_main_body_mesh.set_surface_override_material(2, greater_compare_material)
		_main_body_mesh.set_surface_override_material(1, normal_compare_material)
	elif (left_box as SortItBox).number < (right_box as SortItBox).number:
		_main_body_mesh.set_surface_override_material(2, normal_compare_material)
		_main_body_mesh.set_surface_override_material(1, greater_compare_material)
	else:
		_main_body_mesh.set_surface_override_material(2, greater_compare_material)
		_main_body_mesh.set_surface_override_material(1, greater_compare_material)


func _physics_process(delta):
	_move_and_rotate(delta)
	_stick_boxes()
	_update_comperators()
	_attract_boxes(delta)
