extends Node2D


const DAMAGE := 1
const SPEED := 200

var velocity := Vector2()
var direction := Vector2.ZERO


func _ready() -> void:	
	add_to_group("player_projectiles")
	

func set_projectile_direction(dir):
	direction = dir
	
	$AnimationPlayer.play("RESET")
	
	if direction == Vector2.LEFT and $Sprite.position.x > 0:
		$Sprite.position *= -1
		$Sprite2.position *= -1
		$Sprite3.position *= -1
		$Area2D/CollisionShape2D.position *= -1
	
	elif direction == Vector2.RIGHT and $Sprite.position.x < 0:
		$Sprite.position *= -1
		$Sprite2.position *= -1
		$Sprite3.position *= -1
		$Area2D/CollisionShape2D.position *= -1

func _physics_process(delta):
	velocity.x = direction.x * SPEED * delta

	translate(velocity)



func _on_Area2D_body_entered(body: Node) -> void:
	if body.is_in_group("SOLID"):
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
	if $AnimationPlayer.is_playing():
		return
	
	if area.is_in_group("SHIELD"):
		$AnimationPlayer.play("explode")
		direction = Vector2.ZERO
		
		var SFX = load("res://games/suffro_mania/SFX.tscn").instance()
		SFX.play("bing")
		get_parent().add_child(SFX)
	
	elif area.get_parent().has_method("hit"):
#		$Area2D/CollisionShape2D.disabled = true
		area.get_parent().hit(DAMAGE)
		$AnimationPlayer.play("explode")
		direction = Vector2.ZERO
