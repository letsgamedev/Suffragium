extends Control


func _ready() -> void:
	visible = true
	get_tree().paused = true


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		get_tree().paused = false
		get_parent().get_parent().get_node("BackgroundMusic")
		get_parent().get_node("Fader/Anim").play("fadeOut")
		
		queue_free()
