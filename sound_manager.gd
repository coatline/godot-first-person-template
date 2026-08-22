extends Node

# TODO: Return the sounds back to their respective pools better

const INITIAL_POOL_SIZE: int = 0
const DEFAULT_VOLUME: float = 1.0

# Perceptual loudness curve with a steep slope: short transient sounds (impacts,
# footsteps) need more than -10 dB to read as clearly quieter.
# 1.0 = 0 dB, 0.5 = -20 dB (quarter loudness), 0.25 = -40 dB.
static func volume_to_db(volume: float) -> float:
	if volume <= 0.0:
		return -80.0
	if volume >= 1.0:
		return 0.0
	return 66.4 * log(volume) / log(10.0)

# Linear multiplier equivalent of volume_to_db (for volume_linear-style properties).
static func volume_to_linear(volume: float) -> float:
	if volume <= 0.0:
		return 0.0
	return db_to_linear(volume_to_db(volume))

var pool_2d: Array[AudioStreamPlayer2D] = []
var pool_3d: Array[AudioStreamPlayer3D] = []
var pool_non_spatial: Array[AudioStreamPlayer] = []

func _setup_player(player: Node) -> void:
	player.bus = "Sound"
	player.finished.connect(func(): player.stream = null)
	add_child(player)

func _ready() -> void:
	for i: int in range(INITIAL_POOL_SIZE):
		_add_to_pool_2d()
		_add_to_pool_3d()
		_add_to_pool_non_spatial()

func _add_to_pool_2d() -> AudioStreamPlayer2D:
	var player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
	_setup_player(player)
	pool_2d.append(player)
	return player

func _add_to_pool_3d() -> AudioStreamPlayer3D:
	var player: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	_setup_player(player)
	pool_3d.append(player)
	return player

func _add_to_pool_non_spatial() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	_setup_player(player)
	pool_non_spatial.append(player)
	return player

func _get_player_from_pool(pool: Array, add_func: Callable) -> Node:
	for player: Node in pool:
		if not player.get("playing"):
			return player

	return add_func.call()

func _set_pause_behavior(player: Node, pause_on_pause: bool) -> void:
	if pause_on_pause:
		player.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		player.process_mode = Node.PROCESS_MODE_ALWAYS

func play_sound(sound: Sound, position: Variant, volume: float = DEFAULT_VOLUME, pause_on_pause: bool = true) -> void:
	play_audio_stream(sound.get_random_sound(), position, volume, true, sound.max_carry_distance, sound.pitch_shift, sound.pitch_variation, pause_on_pause)

func play_sound_non_spatial(sound: Sound, volume: float = DEFAULT_VOLUME, pause_on_pause: bool = true) -> void:
	play_audio_stream(sound.get_random_sound(), null, volume, false, sound.max_carry_distance, sound.pitch_shift, sound.pitch_variation, pause_on_pause)

func play_audio_stream(stream: AudioStream, position: Variant = null, volume: float = DEFAULT_VOLUME, spatial: bool = true, max_distance: float = 35.0, pitch_shift: float = 1.0, pitch_variation: float = 0.0, pause_on_pause: bool = true) -> void:
	if stream == null:
		push_warning("Attempted to play a null audio stream.")
		return

	if spatial:
		if position is Vector2:
			var player: AudioStreamPlayer2D = _get_player_from_pool(pool_2d, _add_to_pool_2d) as AudioStreamPlayer2D
			_set_pause_behavior(player, pause_on_pause)
			player.stream = stream
			player.position = position
			player.volume_db = volume_to_db(volume)
			player.max_distance = max_distance
			player.pitch_scale = pitch_shift + randf_range(-pitch_variation, pitch_variation)
			player.play()
		elif position is Vector3:
			var player: AudioStreamPlayer3D = _get_player_from_pool(pool_3d, _add_to_pool_3d) as AudioStreamPlayer3D
			_set_pause_behavior(player, pause_on_pause)
			player.stream = stream
			player.position = position
			player.volume_db = volume_to_db(volume)
			player.max_distance = max_distance
			player.pitch_scale = pitch_shift + randf_range(-pitch_variation, pitch_variation)
			player.play()
		else:
			push_error("Spatial sound requires Vector2 or Vector3 position.")
	else:
		var player: AudioStreamPlayer = _get_player_from_pool(pool_non_spatial, _add_to_pool_non_spatial) as AudioStreamPlayer
		_set_pause_behavior(player, pause_on_pause)
		player.stream = stream
		player.volume_db = volume_to_db(volume)
		player.pitch_scale = pitch_shift + randf_range(-pitch_variation, pitch_variation)
		player.play()
