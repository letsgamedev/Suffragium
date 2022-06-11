class_name SortItPlayer
extends KinematicBody

export(float) var direction_change_speed = 4
export(int) var move_speed = 1000
export(float) var max_speed = 5
export(float) var atrract_speed = 500
export(float) var friction = 0.7
export(float) var max_box_distance = 5.0
export(float) var attracted_distance = 2.7
export(Vector3) var camera_offset = Vector3(-8, 20, 0)
export(Material) var greater_compare_material
export(Material) var normal_compare_material

# Needs to be set by parrent class
var player_index: int
var camera: Camera
var status_display: Control

var last_direction = Vector3.ZERO
var velocity = Vector3.ZERO
var left_magnet_active = false
var right_magnet_active = false

var left_box = null
var right_box = null
onready var _left_anchor = $LeftMagnet/Anchor
onready var _right_anchor = $RightMagnet/Anchor
onready var _players = get_parent()
onready var _main_body_mesh = $Mesh/MainBody


func set_color(color: Color):
	var material: SpatialMaterial = _main_body_mesh.mesh.surface_get_material(0).duplicate()
	material.albedo_color = color
	_main_body_mesh.mesh.surface_set_material(0, material)


func _input(_event):
	var last_left_magnet_active = left_magnet_active
	var last_right_magnet_active = right_magnet_active
	if _players.is_action_just_pressed("left_magnet", player_index):
		left_magnet_active = !left_magnet_active
	elif _players.is_action_just_pressed("right_magnet", player_index):
		right_magnet_active = !right_magnet_active

	# Handel dropping off attached boxes, when dissabeling magnets
	if last_left_magnet_active and not left_magnet_active and left_box != null:
		left_box.linear_velocity = Vector3.ZERO
		left_box.angular_velocity = Vector3.ZERO
		(left_box as Box).reset_despawn()
		left_box = null
	if last_right_magnet_active and not right_magnet_active and right_box != null:
		right_box.linear_velocity = Vector3.ZERO
		right_box.angular_velocity = Vector3.ZERO
		(right_box as Box).reset_despawn()
		right_box = null

	$LeftMagnet/Particles.emitting = left_magnet_active
	$RightMagnet/Particles.emitting = right_magnet_active


func _move_and_rotate(delta):
	var direction = Vector3(0, 0, 0)
	direction.x = _players.get_action_strength("right", player_index)
	direction.z = _players.get_action_strength("down", player_index)

	# This could be improved
	velocity *= friction
	velocity = Vector3(
		clamp(direction.x + velocity.x, -max_speed, max_speed),
		0,
		clamp(direction.z + velocity.z, -max_speed, max_speed)
	)
	var look_at_pos_rel = lerp(last_direction, velocity, delta * direction_change_speed)
	if (look_at_pos_rel - last_direction).length() > 0.01:
		look_at(look_at_pos_rel + transform.origin, Vector3.UP)

	last_direction = look_at_pos_rel
	move_and_slide(Vector3(-look_at_pos_rel.z, -0.5, look_at_pos_rel.x) * delta * move_speed)
	camera.transform.origin = transform.origin + camera_offset


func _attract_block(magnet: Spatial, delta: float):
	var area: Area = magnet.get_node("Area")
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
		nearest.add_force(
			(
				(anchor - nearest.global_transform.origin)
				* Vector3(atrract_speed, atrract_speed * 2, atrract_speed)
				* delta
			),
			Vector3(0, 0, 0)
		)
		# If the box is close enougth attach it
		if (min_distance <= attracted_distance) == true:
			(nearest as Box).stop_despawn()
			return nearest


func _attract_boxes(delta: float):
	if left_magnet_active and left_box == null:
		left_box = _attract_block($LeftMagnet, delta)
	if right_magnet_active and right_box == null:
		right_box = _attract_block($RightMagnet, delta)


func _stick_box(box: RigidBody, anchor: Vector3):
	box.global_transform.origin = anchor  # Keep box at anchor position
	# Keep box rotation in line with the magnet direction (1, 0, 0)
	box.look_at(anchor - (Vector3(1, 0, 0)).rotated(Vector3.UP, rotation.y), Vector3.UP)


func _stick_boxes():
	if left_box != null:
		_stick_box(left_box, _left_anchor.global_transform.origin)
	if right_box != null:
		_stick_box(right_box, _right_anchor.global_transform.origin)


# Updates the triangle indecators on the player to show what number is bigger
# (important for sorting black boxes)
func _update_comperators():
	if left_box == null or right_box == null:
		_main_body_mesh.set_surface_material(2, normal_compare_material)
		_main_body_mesh.set_surface_material(1, normal_compare_material)
		return
	if (left_box as Box).number > (right_box as Box).number:
		_main_body_mesh.set_surface_material(2, greater_compare_material)
		_main_body_mesh.set_surface_material(1, normal_compare_material)
	elif (left_box as Box).number < (right_box as Box).number:
		_main_body_mesh.set_surface_material(2, normal_compare_material)
		_main_body_mesh.set_surface_material(1, greater_compare_material)
	else:
		_main_body_mesh.set_surface_material(2, greater_compare_material)
		_main_body_mesh.set_surface_material(1, greater_compare_material)


func _physics_process(delta):
	_move_and_rotate(delta)
	_stick_boxes()
	_update_comperators()
	_attract_boxes(delta)
