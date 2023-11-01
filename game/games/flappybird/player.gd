extends CharacterBody2D

const UP: Vector2 = Vector2(0, -1)
const FLAP_HEIGHT: float = 200.0  # flap time
const WALL_DISTANCE: float = 1.2  # time between wall spawns
const MAXFALLSPEED: float = 200.0
const GRAVITY: float = 10.0
const END_MESSAGE: String = "You got %s point(s)!"

var timer: float = 0.0  # timer; spawning walls

var motion: Vector2 = Vector2()
var wall: PackedScene = preload("res://games/flappybird/wall_node.tscn")
var score: int = 0
var started: bool = false

@onready var _score_label: Label = $"../../CanvasLayer/ScoreLabel"
@onready var _start_label: Label = $"../../CanvasLayer/StartLabel"
@onready var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _physics_process(delta):
	# handle game start
	if not started:
		if Input.is_action_just_pressed("flap"):
			start_game()
		return

	if position.y > 130:
		end_game()
		return

	if Input.is_action_just_pressed("flap"):
		flap()

	add_to_timer(delta)
	motion.y += GRAVITY
	if motion.y > MAXFALLSPEED:
		motion.y = MAXFALLSPEED
	set_velocity(delta * 60 * motion)
	set_up_direction(UP)
	move_and_slide()
	motion = velocity


# start the game
func start_game():
	_start_label.visible = false
	_rng.randomize()
	started = true


func end_game():
	set_physics_process(false)
	GameManager.end_game(END_MESSAGE % score, score)


# flap when player presses ,,space"
func flap():
	if position.y > -80:
		motion.y = -FLAP_HEIGHT
		$Sound_Jump.play()


# add delta to the timer
func add_to_timer(delta):
	timer += delta

	if timer >= WALL_DISTANCE:
		timer = 0
		spawn_wall()


# spawn a new wall when timer hits 1.2
func spawn_wall():
	var instance = wall.instantiate()

	instance.position = Vector2(300, _rng.randi_range(-60, 60))
	get_parent().call_deferred("add_child", instance)


# remove wall from node if colliding with reset area2d
func _on_Reset_body_entered(body):
	if body.name == "Wall":
		body.queue_free()


# add to score if player passes between 2 walls
func _on_Hitbox_area_entered(area):
	if area.name == "PointHitbox":
		score += 1
		_score_label.text = str(score)
		$Sound_Wall.play()


# reload scene if player hits wall body
func _on_Hitbox_body_entered(body):
	if body.name == "Wall":
		# here would come a death sound when player dies ($Sound_GameEnd)
		# when the gamemanager is evolved enough to handle that, ill add it
		end_game()
