extends VBoxContainer

enum Sorting { ALPHABETICALLY, LAST_PLAYED, LONGEST_PLAYTIME }

var _res_game_card = preload("res://app/scenes/game_card.tscn")
var _res_game_card_add_yours = preload("res://app/scenes/game_card_add_yours.tscn")

@onready var _tab_container: TabContainer = $TabContainer
@onready var _games_grid: GridContainer = $TabContainer/Games/SC/MC/CC/GC
@onready var _about_tab: ScrollContainer = $TabContainer/About


func _ready():
	# add all the games
	var games = GameManager.get_games()
	for game_id in games.keys():
		var game_card = _res_game_card.instantiate()
		_games_grid.add_child(game_card)
		game_card.setup(games[game_id])
	# add contribute card
	var game_card_add_yours = _res_game_card_add_yours.instantiate()
	game_card_add_yours.set_menu_node(self)
	_games_grid.add_child(game_card_add_yours)
	_sort_game_cards(Sorting.ALPHABETICALLY)


# this function is also used by GameCardAddYours
func open_participation_tab():
	var previous_tab = $TabContainer.current_tab
	_tab_container.set_current_tab(1)
	_about_tab.scroll_to(previous_tab, _about_tab.Section.PARTICIPATE)


func _on_ButtonGames_pressed():
	_tab_container.set_current_tab(0)


func _on_ButtonAbout_pressed():
	var previous_tab = $TabContainer.current_tab
	_tab_container.set_current_tab(1)
	_about_tab.scroll_to(previous_tab, _about_tab.Section.ABOUT)


func _on_ButtonParticipate_pressed():
	open_participation_tab()


func _on_ButtonReportBug_pressed():
	var previous_tab = $TabContainer.current_tab
	_tab_container.set_current_tab(1)
	_about_tab.scroll_to(previous_tab, _about_tab.Section.REPORT_A_BUG)


func _on_ButtonSettings_pressed():
	_tab_container.set_current_tab(2)


func _on_OptionButtonSorting_item_selected(index: int):
	_sort_game_cards(index)


func _sort_game_cards(sort_mode):
	var game_cards = _gather_game_card_sort_entries()
	if sort_mode == Sorting.ALPHABETICALLY:
		game_cards.sort_custom(Callable(self, "_sort_alphabetically_by_game_title"))
	elif sort_mode == Sorting.LAST_PLAYED:
		game_cards.sort_custom(Callable(self, "_sort_by_last_played"))
	elif sort_mode == Sorting.LONGEST_PLAYTIME:
		game_cards.sort_custom(Callable(self, "_sort_by_longest_playtime"))
	_rearrange_game_cards(game_cards)


func _gather_game_card_sort_entries() -> Array:
	var game_cards = []
	for i in _games_grid.get_child_count() - 1:
		var game_card = _games_grid.get_child(i)
		var card_entry = {
			"node": game_card,
			"title": game_card.get_title(),
			"playtime": game_card.get_playtime(),
			"last_played": game_card.get_last_played(),
		}
		game_cards.push_back(card_entry)
	return game_cards


func _sort_by_longest_playtime(a: Dictionary, b: Dictionary) -> bool:
	if a["playtime"] > b["playtime"]:
		return true
	return false


func _sort_alphabetically_by_game_title(a: Dictionary, b: Dictionary) -> bool:
	var array = [a["title"], b["title"]]
	array.sort()
	if a["title"] == array[0]:
		return true
	return false


func _sort_by_last_played(a: Dictionary, b: Dictionary) -> bool:
	if a["last_played"] == null:
		return false
	if b["last_played"] == null:
		return true
	if a["last_played"] > b["last_played"]:
		return true
	return false


func _rearrange_game_cards(game_cards: Array):
	for card_entry in game_cards:
		var game_card = card_entry["node"]
		_games_grid.remove_child(game_card)
		_games_grid.add_child(game_card)
	var game_card_add_yours = _games_grid.get_child(0)
	_games_grid.remove_child(game_card_add_yours)
	_games_grid.add_child(game_card_add_yours)
