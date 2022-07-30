extends Area2D

var time := 0.0

onready var _main = get_tree().current_scene
onready var _polygon = $StarPolygon


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_main.count_star()


func _process(delta) -> void:
	self.rotate(delta * 1.5)

	var scale_factor := 0.75 + 0.2 * sin(time * 2.0)
	_polygon.position.x = -scale_factor
	_polygon.position.y = -scale_factor
	_polygon.scale.x = scale_factor
	_polygon.scale.y = scale_factor

	time += delta


func _on_Star_body_entered(body: Node) -> void:
	if not self.visible:
		return
	if body is KinematicBody2D and body.is_in_group("Player"):
		self.visible = false
		_main.collected_star()
