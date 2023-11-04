@tool
extends ScrollContainer
# This script translates a simplified syntax into bbcode for the RichTextLabel to display.
# It can also calculate the position of specific lines. This is used by menu to smooth scroll.
# How to edit the about page:
# 	-Edit the text property of this About node.
# 	-Everything will be translated using tr()
# 		(every key will be substituted anything else stays the same)
# 	-titles can be added by using the title_key at the start of the line.
# 		(this is a shorthand for using [font="res://.../titlefont.tres")
# 	-Any [url] tag will be treated like a link. If you add one color it the same as the others.
# 		(specific color is subject to change)

enum Section { ABOUT, PARTICIPATE, REPORT_A_BUG }

const TITLE_KEY: String = "# "
const ABOUT_PATH: String = "res://app/scenes/about.md"

var _title_theme: Theme = preload("res://app/scenes/title_font_theme.tres")
var _text: String

var _tab_index: int
var _section_titles: Array = []

@onready var _txt_container: VBoxContainer = $MC/VC


func _ready() -> void:
	_load_text()
	_write_text()
	_get_own_tab_index()


func scroll_to(previous_tab: int, section: Section) -> void:
	var smooth_scroll = UserSettings.get_setting("smooth_scroll")
	if previous_tab == _tab_index and smooth_scroll:
		var tween: Tween = get_tree().create_tween()
		var max_y = $MC.size.y - size.y
		var pos_y: float = _section_titles[section].position.y
		var scroll_y = clamp(pos_y, 0, max_y)
		tween.tween_property(
			self,
			"scroll_vertical",
			scroll_y,
			0.4
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	else:
		# workaround: when node was not visible yet, position.y is 0
		await get_tree().process_frame
		var pos_y: float = _section_titles[section].position.y
		set_v_scroll(int(pos_y))


func _load_text() -> void:
	var file = FileAccess.open(ABOUT_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not read ABOUT file.")
		return
	_text = file.get_as_text()


func _write_text() -> void:
	_clear()
	for line in _text.split("\n"):
		if _is_title(line):
			_write_title(line)
		else:
			var link_info: Dictionary = _get_link_info(line)
			if link_info["is_link"]:
				_write_link(link_info["text"], link_info["url"])
			else:
				_write_line(line)


func _clear() -> void:
	for child in _txt_container.get_children():
		child.queue_free()


func _is_title(txt: String) -> bool:
	return txt.begins_with(TITLE_KEY)


func _write_title(txt: String) -> void:
	txt = txt.trim_prefix(TITLE_KEY)
	var label: Label = _make_label(txt, _title_theme)
	_section_titles.push_back(label)
	_txt_container.add_child(label)


func _get_link_info(txt: String) -> Dictionary:
	var regex: RegEx = RegEx.new()
	regex.compile("\\[([\\w ]+)\\]\\((https?:\\/\\/[\\w\\/.\\-#]+) ?(\"[\\w ,-äöüÄÖÜ]+\")?\\)")
	var regex_match: RegExMatch = regex.search(txt)
	var is_link: bool = regex_match != null
	return {
		"is_link": is_link,
		"text": "" if not is_link else regex_match.get_string(1),
		"url": "" if not is_link else regex_match.get_string(2),
		"alt": "" if not is_link else regex_match.get_string(3)
	}


func _write_link(text: String, url: String) -> void:
	var r_label: RichTextLabel = RichTextLabel.new()
	var link_as_bbcode: String = "[color=#649bff][url=%s]%s[/url][/color]" % [url, text]
	r_label.set_use_bbcode(true)
	r_label.set_fit_content(true)
	r_label.append_text(link_as_bbcode)
	r_label.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
	r_label.connect("meta_clicked", Utils.open_url)
	_txt_container.add_child(r_label)


func _write_line(txt: String) -> void:
	_txt_container.add_child(_make_label(txt, null))


func _make_label(txt: String, font_theme: Theme) -> Label:
	var label: Label = Label.new()
	label.set_text(txt)
	label.set_theme(font_theme)
	label.set_autowrap_mode(TextServer.AUTOWRAP_WORD_SMART)
	return label


func _get_own_tab_index() -> void:
	var tab_container: TabContainer = get_parent()
	for tab_index in tab_container.get_tab_count():
		if tab_container.get_tab_title(tab_index) == name:
			_tab_index = tab_index
			return
