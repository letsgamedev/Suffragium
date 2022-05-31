extends Spatial

var zoom_min: float = 10
var zoom_max: float = 40

onready var main = get_tree().current_scene


func _process(_delta):
	var center: Vector3 = _find_players_center_translation()
	translation = center
	var distance = _find_lonagest_distance_to_center(center) + 6
	distance = min(max(distance, zoom_min), zoom_max)
	$Pivot/Camera.translation.y = distance


func _find_players_center_translation() -> Vector3:
	var center_translation: Vector3 = Vector3.ZERO
	for player_pawn in main.player_pawns:
		center_translation += player_pawn.translation
	return center_translation / main.player_pawns.size()


func _find_lonagest_distance_to_center(center: Vector3) -> float:
	var distance: float = 0
	for player_pawn in main.player_pawns:
		if distance < player_pawn.translation.distance_to(center):
			distance = player_pawn.translation.distance_to(center)
	return distance
