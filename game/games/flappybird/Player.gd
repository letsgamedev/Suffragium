extends KinematicBody2D

const UP = Vector2(0, -1)
const FLAP_HEIGHT = 200  # flap time
const MAXFALLSPEED = 200
const GRAVITY = 10
const END_MESSAGE := "You got %s point(s)!"

var timer = 0  # timer; spawning walls

var motion = Vector2()
var wall = preload("res://games/flappybird/WallNode.tscn")
var score = 0
var gameRunning = false

onready var _score_label := $"../../CanvasLayer/RichTextLabel"
onready var _rng := RandomNumberGenerator.new()

func ready():
	pass


# called every frame
func _physics_process(delta):
	
	# handle game start
	if not gameRunning and Input.is_action_just_pressed("flap"):
		start_game()
	
	# handle player physics behaviour
	if gameRunning:
		addToTimer(delta)

		motion.y += GRAVITY
		if motion.y > MAXFALLSPEED:
			motion.y = MAXFALLSPEED

		if Input.is_action_just_pressed("flap"):
			flap()
	
	
	if position.y > 130:
		GameManager.end_game(END_MESSAGE % score)
		return

	motion = move_and_slide(delta * 60 * motion, UP)

	_score_label.text = str(score)


# start the game
func start_game():
	get_parent().get_parent().get_node("CanvasLayer/RichTextLabel2").visible = false
	_rng.randomize()
	gameRunning = true


# flap when player presses ,,space"
func flap():
	if position.y > -80:
		motion.y = -FLAP_HEIGHT
		$Sound_Jump.play()


# add delta to the timer
func addToTimer(delta):
	timer += delta
	
	if timer >= 1.2:
		timer = 0
		spawn_wall()


# spawn a new wall when timer hits 1.2
func spawn_wall():
	var instance = wall.instance()
	
	instance.position = Vector2(500, _rng.randi_range(-60, 60))
	get_parent().call_deferred("add_child", instance)


# remove wall from node if colliding with reset area2d
func _on_Reset_body_entered(body):
	if body.name == "Wall":
		body.queue_free()


# add to score if player passes between 2 walls
func _on_Hitbox_area_entered(area):
	if area.name == "PointHitbox":
		score += 1
		$Sound_Wall.play()


# reload scene if player hits wall body
func _on_Hitbox_body_entered(body):
	if body.name == "Wall":
		# here would come a death sound when player dies (which is already fully implemented ($Sound_GameEnd)) / when the gamemanager is evolved enough to handle that, ill add it
		GameManager.end_game(END_MESSAGE % score)
