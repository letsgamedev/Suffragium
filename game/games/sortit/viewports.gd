extends GridContainer

const STATUS_DISPLAY_SCENE = preload("res://games/sortit/StatusDisplay.tscn")
onready var _players: Node = $"../Players"
onready var _minimap_camera: Camera = $MiniMapCamera


func _add_viewport_container() -> Viewport:
	# Create viewport and viewport container
	var viewport_container = ViewportContainer.new()
	viewport_container.stretch = true
	viewport_container.size_flags_horizontal = SIZE_EXPAND_FILL
	viewport_container.size_flags_vertical = SIZE_EXPAND_FILL
	var viewport = Viewport.new()
	viewport.shadow_atlas_size = 1
	viewport.msaa = Viewport.MSAA_4X
	viewport_container.add_child(viewport)
	# Add viewport container
	add_child(viewport_container)
	return viewport


func create_viewports():
	var player_count = _players.player_count
	if player_count == 1:
		columns = 1
	for i in range(player_count):
		var viewport = _add_viewport_container()
		# Create camerea and status display for player
		var camera = Camera.new()
		camera.fov = 50
		camera.rotation_degrees.x = -70
		camera.rotation_degrees.y = -90
		viewport.add_child(camera)
		var status_display = STATUS_DISPLAY_SCENE.instance()
		viewport.add_child(status_display)
		# Assign camerea and status display to player
		var player = _players.get_child(i)
		player.camera = camera
		player.status_display = status_display
	if player_count == 3:
		# Move minimap camera into new viewport to fill empty spot
		var viewport = _add_viewport_container()
		viewport.shadow_atlas_size = 0  # Dissable shadows for mini map
		remove_child(_minimap_camera)
		viewport.add_child(_minimap_camera)
	else:
		_minimap_camera.hide()
