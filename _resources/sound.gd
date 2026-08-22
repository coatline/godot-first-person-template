extends Resource
class_name Sound

@export var audio_clips: Array[AudioStream] = []
@export var max_carry_distance: float = 35.0
@export var pitch_variation: float = 0.1
@export var pitch_shift: float = 1.0
@export var name: String

func get_random_sound():
	return audio_clips[randi_range(0, len(audio_clips) - 1)]
