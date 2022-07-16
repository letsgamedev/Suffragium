extends Node2D


const DAMAGE := 1
const SPEED := 100

var direction := Vector2.ZERO

var myPos : Vector2
var vector : Vector2

func _ready() -> void:	
	add_to_group("enemy_projectiles")
	
	

func set_projectile_direction(dir):
	direction = dir
	
	myPos = self.global_position
	vector = -(myPos - direction).normalized()
	

	
func _physics_process(delta):	
	position += vector * delta * SPEED



func _on_Area2D_body_entered(body: Node) -> void:
	if body.name == "TileMap":
		$AnimationPlayer.play("explode")
		direction = Vector2.ZERO
	



func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "explode":
		kill()


func _on_VisibilityNotifier2D_viewport_exited(viewport: Viewport) -> void:
	kill()



func kill() -> void:
	$AnimationPlayer.play("RESET")
	set_physics_process(false)
	position = Vector2.ZERO
	hide()
	


func _on_Area2D_area_entered(area: Area2D) -> void:
	if area.is_in_group("PLAYER"):
		$Area2D/CollisionShape2D.disabled = true
		area.hp -= DAMAGE
		area.get_parent().hitstun = area.get_parent().hitstun_max
		$AnimationPlayer.play("explode")
		direction = Vector2.ZERO
