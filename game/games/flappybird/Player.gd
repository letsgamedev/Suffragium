extends KinematicBody2D

const UP = Vector2(0, -1)
const FLAP_HEIGHT = 200  # flap time
const MAXFALLSPEED = 200
const GRAVITY = 10
const END_MESSAGE := "You got %s points!"

var timer = 0  # timer; spawning walls

var motion = Vector2()
var wall = preload("res://games/flappybird/WallNode.tscn")
var score = 0


func ready():
	pass


func _physics_process(delta):
	timer += delta

	if timer >= 1:
		timer = 0
		spawn_wall()

	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED

	if Input.is_action_just_pressed("flap"):
		if position.y > -80:
			motion.y = -FLAP_HEIGHT

	if position.y > 130:
		GameManager.end_game(END_MESSAGE % score)
		return

	motion = move_and_slide(delta * 60 * motion, UP)

	get_parent().get_parent().get_node("CanvasLayer/RichTextLabel").text = str(score)


# spawn a new wall at the right side of the screen
func spawn_wall():
	var instance = wall.instance()
	rand_seed(rand_range(0, 25))
	instance.position = Vector2(500, rand_range(-60, 60))
	get_parent().call_deferred("add_child", instance)


# remove wall from node if colliding with reset area2d
func _on_Reset_body_entered(body):
	if body.name == "Wall":
		body.queue_free()


# add to score if player passes between 2 walls
func _on_Hitbox_area_entered(area):
	if area.name == "PointHitbox":
		score += 1
		print(score)


# reload scene if player hits wall body
func _on_Hitbox_body_entered(body):
	if body.name == "Wall":
		GameManager.end_game(END_MESSAGE % score)
