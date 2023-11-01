extends ScrollContainer

const LOCALE_NAMES = {
	"en": "English",
	"de": "Deutsch",
}

var languages = []

@onready var language_selection: OptionButton = $MC/VC/VC/Language/OptionButton


func _ready():
	_setup()


func _setup():
	_setup_language_selection()
	_setup_smooth_scroll_setting()


func _setup_language_selection():
	language_selection.clear()
	languages.clear()
	var active_language_code = TranslationServer.get_locale()
	for language_code in TranslationServer.get_loaded_locales():
		if LOCALE_NAMES.has(language_code):
			language_selection.add_item(LOCALE_NAMES[language_code])
		else:
			language_selection.add_item(TranslationServer.get_locale_name(language_code))
		languages.push_back(language_code)
		if language_code == active_language_code:
			language_selection.select(language_selection.get_item_count() - 1)


func _setup_smooth_scroll_setting():
	var smooth_scroll = UserSettings.get_setting("smooth_scroll")
	$MC/VC/VC/SmoothScroll/CheckBox.button_pressed = smooth_scroll


func _on_ButtonResetDefaults_pressed():
	UserSettings.reset_to_default()
	_setup()


func _on_LanguageSelection_item_selected(index: int):
	var language_code = languages[index]
	UserSettings.set_setting("language_code", language_code)


func _on_CheckBoxSmoothScroll_toggled(button_pressed: bool):
	UserSettings.set_setting("smooth_scroll", button_pressed)
