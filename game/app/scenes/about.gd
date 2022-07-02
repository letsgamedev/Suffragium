tool
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

export(String) var title_key := "# "
# This is the About text. To add a Title use the title key
export(String, MULTILINE) var text := "" setget set_text
export(Font) var title_font: Font

onready var _label := $MC/RichTextLabel


# this is needed to ract to any language changes that might need retranslating
func _notification(what):
	if what == NOTIFICATION_TRANSLATION_CHANGED:
		_write_def()


func _ready():
	_write_to_label()


func set_text(val: String):
	text = val
	# updating this is only needed in editor
	# In-game it is updated by other sources
	if Engine.editor_hint:
		_write_def()


func _write_to_label():
	# Fails in Editor when you edit the script.
	if !is_instance_valid(_label):
		return
	# this part might need a refactor
	_label.clear()
	for line in text.split("\n"):
		# this loop treats every line in sequence
		var is_title: bool = line.begins_with(title_key)
		line = line.trim_prefix(title_key)
		if is_title:
			_label.push_font(title_font)

		# first refers to the first part of the line
		var first := true
		for key in line.split(" "):
			# each part of this might be a translation key, one or more bb tags,
			# one or more closing tags, or just text
			if key.match("[/*]"):
				# RichTextLabel requires pop() when closing tag from previus append_bbcode()
				for _i in range(key.count("[")):
					_label.pop()
			else:
				# append the translation of whatever key is
				# anything not a key will be returned unchanged
				# tr("[color=blue]") = "[color=blue]"
				if first:
					# the first part of the line shouldn't have a seperating " " infront of it
					_label.append_bbcode(tr(key))
				else:
					_label.append_bbcode(" " + tr(key))
			first = false
		# close the [font] tag for the title font
		if is_title:
			_label.pop()
		_label.newline()


# determines how far down to scroll until the line is found
# !this is searched in the untranslated text
func get_line_absolute_height(line: String):
	var pos: float = 0
	var lines: Array = text.split("\n")
	var font_height: int = _label.get_font("normal_font").get_height()
	var line_spacing: float = _label.get_constant("line_separation")

	var line_location := text.find(line)
	# count won't work if location is 0. If it is the height is also 0
	if line_location == 0:
		return 0
	# go over every line and add its height
	for i in text.count("\n", 0, line_location):
		# i is the line to add the size of
		if lines[i].begins_with(title_key):
			pos += title_font.get_height()
		else:
			pos += font_height
		pos += line_spacing
	return pos


# helper to call _write_to_label deferred
# (_write_to_label will be called at the end of the frame after everything else)
func _write_def():
	call_deferred("_write_to_label")


# This is called when the user clicks on a [url] tag in the label.
# Utils.open_url() actually supports more than just urls
func _on_RichTextLabel_meta_clicked(meta):
	Utils.open_url(meta)
