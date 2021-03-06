extends Node

const SETTINGS_FILENAME = "user://user_settings.suffragiumsave"

var settings = {
	"language_code": null,
	"smooth_scroll": null,
}


func _ready():
	_set_defaults()
	_load_settings_from_file()
	_apply_loaded_settings()


func reset_to_default():
	_set_defaults()
	_save_settings_to_file()
	_apply_loaded_settings()


func set_setting(setting_key: String, value):
	if settings.has(setting_key):
		settings[setting_key] = value
		_save_settings_to_file()
		_apply_setting(setting_key)
	else:
		push_error("can't set setting_key '%s' (no match)" % setting_key)


func get_setting(setting_key: String):
	if settings.has(setting_key):
		return settings[setting_key]
	push_error("can't get setting_key '%s' (no match)" % setting_key)


func _set_defaults():
	settings["language_code"] = OS.get_locale_language()
	settings["smooth_scroll"] = true


func _load_settings_from_file():
	var save_file = File.new()
	if not save_file.file_exists(SETTINGS_FILENAME):
		_save_settings_to_file()
		return
	save_file.open(SETTINGS_FILENAME, File.READ)
	var save_dict = parse_json(save_file.get_line())
	for setting_key in save_dict:
		if settings.has(setting_key):
			settings[setting_key] = save_dict[setting_key]
		else:
			push_error("setting_key '%s' present in save_file has no match" % setting_key)
	save_file.close()


func _apply_loaded_settings():
	TranslationServer.set_locale(settings["language_code"])


func _save_settings_to_file():
	var save_dict = settings.duplicate()
	var save_file = File.new()
	save_file.open(SETTINGS_FILENAME, File.WRITE)
	save_file.store_line(to_json(save_dict))
	save_file.close()


func _apply_setting(setting_key):
	if setting_key == "language_code":
		TranslationServer.set_locale(settings["language_code"])
	elif setting_key == "smooth_scroll":
		return
