extends Node
# Autoload: MusicManager

@export var default_music_path: String = ""
@export var procedural_pad: bool = true

var player: AudioStreamPlayer

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.bus = "Music"
	add_child(player)

	var file_stream: AudioStream = null
	if default_music_path != "":
		file_stream = load(default_music_path) as AudioStream

	if file_stream:
		player.stream = file_stream
		player.play()

func play_stream(stream: AudioStream) -> void:
	player.stream = stream
	player.play()

func stop() -> void:
	player.stop()
