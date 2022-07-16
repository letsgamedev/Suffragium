extends Sprite

const SPEED = 1.25

var size := 8
var velocity := Vector2.ZERO

var rng = RandomNumberGenerator.new()

var age := 0
var maxage := 0

const COLORS = ["#FFF200", "#FF7F27", "#880015", "#340e36", "#444444"]

func _ready() -> void:
	rng.randomize()
	size = rng.randi_range(6,9)
	
	frame = 9 - (size-1)
	
	velocity.x = rng.randf_range(-1,1)
	velocity.y = rng.randf_range(-1,1)
	
	age = rng.randi_range(0,5)
	maxage = rng.randi_range(15,30)


func _process(delta: float) -> void:
	if age > 10:
		modulate = COLORS[0]
	if age > 12:
		modulate = COLORS[1]
	if age > 18:
		modulate = COLORS[2]
	if age > 20:
		modulate = COLORS[3]
	if age > 25:
		modulate = COLORS[4]
		
	position += velocity * SPEED * (1- age/maxage)
	
	age += 1
	
	if age > maxage:
		frame += 1
		age -= 5
		if frame > 7:
			queue_free() 
