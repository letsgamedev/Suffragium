class_name SortItBox
extends RigidBody

signal despawn(number)

const NUMBERS: MeshLibrary = preload("res://games/sortit/assets/numbers.tres")

export(int) var max_number = 20
export(float) var black_box_chance = 0.1
export(Material) var normal_material
export(Material) var black_material
export(float) var number_spacing = 0.1
export(float) var number_scale = 0.8

var number: int = 0
var is_black: bool = false


func stop_despawn():
	$"DespawnTimer".stop()


func reset_despawn():
	$"DespawnTimer".start()


func _get_number_mesh_instance() -> MeshInstance:
	var number_string = str(number)
	var mesh = ArrayMesh.new()
	var x_offset = 0
	var last_x_offset = 0
	# Add mesh for every diget in the number
	for i in len(number_string):
		# Get diget mesh vertecies
		var c = number_string[i]
		var diget_mesh = NUMBERS.get_item_mesh(9 - int(c))
		var diget_mesh_arrays = diget_mesh.surface_get_arrays(0)
		var vertecies = diget_mesh_arrays[Mesh.ARRAY_VERTEX]
		# Offset diget vertecies to end of last diget
		var max_x = 0
		for vertex_index in len(vertecies):
			var vertex = vertecies[vertex_index]
			if vertex.x > max_x:
				max_x = vertex.x
			vertecies[vertex_index] = vertex + Vector3(x_offset, 0, 0)
		# Calculate x offset for next diget
		last_x_offset = x_offset
		x_offset += max_x + number_spacing
		# Set offset vertcies back into surface arrays
		diget_mesh_arrays[Mesh.ARRAY_VERTEX] = vertecies
		# Add diget surface arrays to number mesh
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, diget_mesh_arrays)
		mesh.surface_set_material(i, black_material)
	# Create mesh instance with number mesh
	var mesh_instance = MeshInstance.new()
	mesh_instance.mesh = mesh
	# Center mesh instance
	var new_scale = $mesh.scale.x / max(last_x_offset, $mesh.scale.x) * number_scale
	mesh_instance.scale = Vector3(new_scale, new_scale, new_scale)
	mesh_instance.transform.origin = Vector3((last_x_offset * new_scale) / 2, 0, 0)
	return mesh_instance


func _add_number_at(mesh_instance: MeshInstance, pos: Vector3):
	# Create parent node to act as a centered pivot point
	var parent = Spatial.new()
	parent.transform.origin = pos
	# Add number mesh to pivot with offset position
	mesh_instance.transform.origin = -mesh_instance.transform.origin
	parent.add_child(mesh_instance)
	# Rotate number to point according to the anchor position (corresponding to the sides)
	if pos.x > 0:
		parent.rotation_degrees.z = -90
	elif pos.x < 0:
		parent.rotation_degrees.z = 90
	elif pos.z > 0:
		parent.rotation_degrees.x = 90
	elif pos.z < 0:
		parent.rotation_degrees.x = -90
	elif pos.y < 0:
		parent.rotation_degrees.y = 180
	add_child(parent)


func _ready():
	self.number = int(floor(rand_range(0, max_number + 1)))
	self.is_black = randf() < black_box_chance
	if self.is_black:
		$mesh.set_surface_material(0, black_material)
	else:
		$mesh.set_surface_material(0, normal_material)
	if not is_black:
		var mesh_instance = _get_number_mesh_instance()
		# Add other rotations too (non trival with current version of _get_number_mesh_instance)
		_add_number_at(mesh_instance.duplicate(DUPLICATE_USE_INSTANCING), $Up.transform.origin)
		_add_number_at(mesh_instance.duplicate(DUPLICATE_USE_INSTANCING), $Down.transform.origin)
		_add_number_at(mesh_instance.duplicate(DUPLICATE_USE_INSTANCING), $Left.transform.origin)
		_add_number_at(mesh_instance.duplicate(DUPLICATE_USE_INSTANCING), $Right.transform.origin)
		_add_number_at(mesh_instance.duplicate(DUPLICATE_USE_INSTANCING), $Forward.transform.origin)
		_add_number_at(mesh_instance, $Backward.transform.origin)


func _on_despawn_timer_timeout():
	emit_signal("despawn", number)
	queue_free()  # kys
