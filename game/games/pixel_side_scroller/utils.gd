class_name PixelSideScrollerUtils

enum Features { MOVE, JUMP }

const GROUND_CHARACTER = "-"
const SPIKE_CHARACTER = "^"

const CHAR_WIDTH = 4

static func initialize_ground_collider_size(collision, text) -> void:
	var ground_width = text.length() * CHAR_WIDTH
	collision.position.x = ground_width
	collision.shape = RectangleShape2D.new()
	collision.shape.extents = Vector2(ground_width - 1, 0.5)
