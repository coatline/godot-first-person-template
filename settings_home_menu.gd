extends UIMenu
class_name SettingsHomeMenu

@export var audio_button: Button
@export var display_button: Button
@export var gameplay_button: Button
@export var controls_button: Button

@export var audio_settings_menu: AudioSettingsMenu
@export var display_settings_menu: DisplaySettingsMenu
@export var gameplay_settings_menu: GameplaySettingsMenu
@export var controls_settings_menu: ControlsSettingsMenu

func _ready() -> void:
	audio_button.pressed.connect(audio_settings_menu.open)
	display_button.pressed.connect(display_settings_menu.open)
	gameplay_button.pressed.connect(gameplay_settings_menu.open)
	controls_button.pressed.connect(controls_settings_menu.open)
