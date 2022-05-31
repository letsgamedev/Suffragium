extends Spatial

onready var main = get_tree().current_scene


func _process(_delta):
	translation = _find_players_center_translation()


func _find_players_center_translation() -> Vector3:
	var center_translation: Vector3 = Vector3.ZERO
	for player_pawn in main.player_pawns:
		center_translation += player_pawn.translation
	return center_translation / main.player_pawns.size()
