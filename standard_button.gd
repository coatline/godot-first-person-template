extends Button

@export var unhovered_sound: Sound
@export var hovered_sound: Sound
@export var pressed_sound: Sound

func _ready() -> void:
	pressed.connect(func(): SoundManager.play_sound_non_spatial(pressed_sound, 1.0, false))
	mouse_entered.connect(func(): SoundManager.play_sound_non_spatial(hovered_sound, 1.0, false))
	mouse_exited.connect(func(): SoundManager.play_sound_non_spatial(unhovered_sound, 1.0, false))
