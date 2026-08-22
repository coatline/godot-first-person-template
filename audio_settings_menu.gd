extends UIMenu
class_name AudioSettingsMenu

@export var master_volume_h_slider: HSlider
@export var sound_volume_h_slider: HSlider
@export var music_volume_h_slider: HSlider
@export var reset_button: Button

func _ready() -> void:
	master_volume_h_slider.value = SettingsSaveManager.master_volume * 100.0
	sound_volume_h_slider.value = SettingsSaveManager.sound_volume * 100.0
	music_volume_h_slider.value = SettingsSaveManager.music_volume * 100.0
	master_volume_h_slider.value_changed.connect(_on_master_volume_changed)
	sound_volume_h_slider.value_changed.connect(_on_sound_volume_changed)
	music_volume_h_slider.value_changed.connect(_on_music_volume_changed)
	reset_button.pressed.connect(_on_reset_pressed)

func _on_master_volume_changed(value: float) -> void:
	SettingsSaveManager.set_master_volume(remap(value, 0, 100, 0, 1))

func _on_sound_volume_changed(value: float) -> void:
	SettingsSaveManager.set_sound_volume(remap(value, 0, 100, 0, 1))

func _on_music_volume_changed(value: float) -> void:
	SettingsSaveManager.set_music_volume(remap(value, 0, 100, 0, 1))

func _on_reset_pressed() -> void:
	SettingsSaveManager.reset_audio_settings()
	master_volume_h_slider.set_value_no_signal(SettingsSaveManager.master_volume * 100.0)
	sound_volume_h_slider.set_value_no_signal(SettingsSaveManager.sound_volume * 100.0)
	music_volume_h_slider.set_value_no_signal(SettingsSaveManager.music_volume * 100.0)
