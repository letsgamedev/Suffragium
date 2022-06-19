extends Node

export(float) var player_size = 5.0
export(float) var player_height = 0.0

var _players
onready var _impostors = $Impostors


func set_players(players: Array):
	_players = players
	# Create impostor for every player
	for i in range(len(players)):
		var player: KinematicBody = _players[i]
		# Copy all sub meshes into new impostor node
		var impostor = Spatial.new()
		for mesh in player.get_node("Mesh").get_children():
			# Duplicate mesh and only show it on the mini map
			var impostor_mesh = mesh.duplicate()
			(impostor_mesh as MeshInstance).set_layer_mask_bit(0, false)
			(impostor_mesh as MeshInstance).set_layer_mask_bit(1, false)
			(impostor_mesh as MeshInstance).set_layer_mask_bit(2, true)
			impostor_mesh.cast_shadow = MeshInstance.SHADOW_CASTING_SETTING_OFF
			impostor_mesh.generate_lightmap = false
			impostor.add_child(impostor_mesh)
		# Offset impostor to be at correct height
		impostor.scale *= player_size
		impostor.transform.origin = Vector3(0, player_height + player_size / 2.0, 0)
		_impostors.add_child(impostor)
		$MiniMapCamera.show()


func _process(_delta):
	# Move and rotate the impostors
	# So that they are at the actual player positions and rotations
	for i in range(len(_players)):
		var player: KinematicBody = _players[i]
		var imposter: Spatial = _impostors.get_child(i)
		var player_pos = player.global_transform.origin
		var imposter_pos = imposter.global_transform.origin
		imposter_pos = Vector3(player_pos.x, imposter_pos.y, player_pos.z)
		imposter.global_transform.origin = imposter_pos
		imposter.rotation = player.rotation
