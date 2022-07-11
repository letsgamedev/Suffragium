extends Control

var _feature: int = PixelSideScrollerUtils.Features.MOVE
var _feature_triggered: Array = []


func _init() -> void:
	hide()
	# Init _feature_triggered
	for _i in range(PixelSideScrollerUtils.Features.size()):
		_feature_triggered.append(false)


func display(feature: int) -> void:
	_feature = feature
	# Dont show help box if feature was already shown this run
	if _feature_triggered[_feature]:
		return
	# Show help box
	_feature = feature
	$TabContainer.current_tab = _feature
	_feature_triggered[_feature] = true
	show()


func used_feature(used_feature: int) -> void:
	if visible and _feature == used_feature:
		hide()
