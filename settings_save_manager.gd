extends Node

# SettingsSaveManager Autoload Singleton

const SETTINGS_PATH: String = "user://settings.cfg"

# 0 - 100
const DEFAULT_MOUSE_SENSITIVITY: float = 50.0
# Actual
const DEFAULT_FOV: float = 75.0
const DEFAULT_CAMERA_X_INVERTED: bool = false
const DEFAULT_CAMERA_Y_INVERTED: bool = false
const DEFAULT_HEAD_BOB_INTENSITY: float = 50.0
const DEFAULT_SPRINT_FOV_BOOST_INTENSITY: float = 50.0
const DEFAULT_TOGGLE_SPRINT: bool = true

const DEFAULT_RESOLUTION: Vector2i = Vector2i(1920, 1080)
const DEFAULT_WINDOW_MODE: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_WINDOWED
const DEFAULT_VSYNC: DisplayServer.VSyncMode = DisplayServer.VSYNC_ENABLED
const DEFAULT_FPS_LIMIT: int = 0
const DEFAULT_MONITOR: int = 0

const DEFAULT_MASTER_VOLUME: float = 1.0
const DEFAULT_SOUND_VOLUME: float = 1.0
const DEFAULT_MUSIC_VOLUME: float = 1.0

signal mouse_sensitivity_changed(value: float)
signal fov_changed(value: float)
signal camera_x_inverted_changed(is_inverted: bool)
signal camera_y_inverted_changed(is_inverted: bool)
signal head_bob_intensity_changed(value: float)
signal sprint_fov_boost_intensity_changed(value: float)
signal toggle_sprint_changed(value: bool)

var settings_file: ConfigFile = ConfigFile.new()

var mouse_sensitivity: float = DEFAULT_MOUSE_SENSITIVITY
var fov: float = DEFAULT_FOV
var camera_x_inverted: bool = DEFAULT_CAMERA_X_INVERTED
var camera_y_inverted: bool = DEFAULT_CAMERA_Y_INVERTED
var head_bob_intensity: float = DEFAULT_HEAD_BOB_INTENSITY
var sprint_fov_boost_intensity: float = DEFAULT_SPRINT_FOV_BOOST_INTENSITY
var toggle_sprint: bool = DEFAULT_TOGGLE_SPRINT

var resolution: Vector2i = DEFAULT_RESOLUTION
var windowed_resolution: Vector2i = DEFAULT_RESOLUTION
var window_mode: DisplayServer.WindowMode = DEFAULT_WINDOW_MODE
var vsync: DisplayServer.VSyncMode = DEFAULT_VSYNC
var fps_limit: int = DEFAULT_FPS_LIMIT
var monitor: int = DEFAULT_MONITOR

var master_volume: float = DEFAULT_MASTER_VOLUME
var sound_volume: float = DEFAULT_SOUND_VOLUME
var music_volume: float = DEFAULT_MUSIC_VOLUME

const INPUT_SECTION_LEGACY: String = "input"
const INPUT_SECTION_KEYBOARD: String = "input_keyboard"
const INPUT_SECTION_GAMEPAD: String = "input_gamepad"

# Full default event lists per action, plus per-device splits
var default_input_map: Dictionary = {}
var default_keyboard_map: Dictionary = {}
var default_gamepad_map: Dictionary = {}


func _init() -> void:
	_capture_default_input_map()
	load_settings()


func save_settings() -> void:
	settings_file.clear()

	settings_file.set_value("video", "monitor", monitor)
	settings_file.set_value("video", "resolution", resolution)
	settings_file.set_value("video", "windowed_resolution", windowed_resolution)
	settings_file.set_value("video", "window_mode", window_mode)
	settings_file.set_value("video", "vsync", vsync)
	settings_file.set_value("video", "fps_limit", fps_limit)

	settings_file.set_value("audio", "master_volume", master_volume)
	settings_file.set_value("audio", "sound_volume", sound_volume)
	settings_file.set_value("audio", "music_volume", music_volume)

	settings_file.set_value("gameplay", "mouse_sensitivity", mouse_sensitivity)
	settings_file.set_value("gameplay", "camera_x_inverted", camera_x_inverted)
	settings_file.set_value("gameplay", "camera_y_inverted", camera_y_inverted)
	settings_file.set_value("gameplay", "fov", fov)
	settings_file.set_value("gameplay", "head_bob_intensity", head_bob_intensity)
	settings_file.set_value("gameplay", "sprint_fov_boost_intensity", sprint_fov_boost_intensity)
	settings_file.set_value("gameplay", "toggle_sprint", toggle_sprint)

	_write_input_map()

	settings_file.save(SETTINGS_PATH)


func load_settings() -> void:
	if settings_file.load(SETTINGS_PATH) != OK:
		reset_to_defaults()
		return

	monitor = settings_file.get_value("video", "monitor", DEFAULT_MONITOR)
	monitor = clampi(monitor, 0, max(0, DisplayServer.get_screen_count() - 1))
	resolution = settings_file.get_value("video", "resolution", DEFAULT_RESOLUTION)
	windowed_resolution = settings_file.get_value("video", "windowed_resolution", resolution)
	window_mode = settings_file.get_value("video", "window_mode", DEFAULT_WINDOW_MODE)
	vsync = settings_file.get_value("video", "vsync", DEFAULT_VSYNC)
	fps_limit = settings_file.get_value("video", "fps_limit", DEFAULT_FPS_LIMIT)

	master_volume = settings_file.get_value("audio", "master_volume", DEFAULT_MASTER_VOLUME)
	sound_volume = settings_file.get_value("audio", "sound_volume", DEFAULT_SOUND_VOLUME)
	music_volume = settings_file.get_value("audio", "music_volume", DEFAULT_MUSIC_VOLUME)

	mouse_sensitivity = settings_file.get_value("gameplay", "mouse_sensitivity", DEFAULT_MOUSE_SENSITIVITY)
	camera_x_inverted = settings_file.get_value("gameplay", "camera_x_inverted", DEFAULT_CAMERA_X_INVERTED)
	camera_y_inverted = settings_file.get_value("gameplay", "camera_y_inverted", DEFAULT_CAMERA_Y_INVERTED)
	fov = settings_file.get_value("gameplay", "fov", DEFAULT_FOV)
	head_bob_intensity = settings_file.get_value("gameplay", "head_bob_intensity", DEFAULT_HEAD_BOB_INTENSITY)
	sprint_fov_boost_intensity = settings_file.get_value("gameplay", "sprint_fov_boost_intensity", DEFAULT_SPRINT_FOV_BOOST_INTENSITY)
	toggle_sprint = settings_file.get_value("gameplay", "toggle_sprint", DEFAULT_TOGGLE_SPRINT)

	load_input_map()
	_apply_settings()


func reset_to_defaults() -> void:
	reset_display_settings(false)
	reset_gameplay_settings(false)
	reset_audio_settings(false)
	_apply_settings()
	save_settings()


func reset_display_settings(save: bool = true) -> void:
	monitor = clampi(DEFAULT_MONITOR, 0, max(0, DisplayServer.get_screen_count() - 1))
	resolution = DEFAULT_RESOLUTION
	windowed_resolution = DEFAULT_RESOLUTION
	window_mode = DEFAULT_WINDOW_MODE
	vsync = DEFAULT_VSYNC
	fps_limit = DEFAULT_FPS_LIMIT

	if save:
		_apply_settings()
		save_settings()


func reset_gameplay_settings(save: bool = true) -> void:
	mouse_sensitivity = DEFAULT_MOUSE_SENSITIVITY
	fov = DEFAULT_FOV
	camera_x_inverted = DEFAULT_CAMERA_X_INVERTED
	camera_y_inverted = DEFAULT_CAMERA_Y_INVERTED
	head_bob_intensity = DEFAULT_HEAD_BOB_INTENSITY
	sprint_fov_boost_intensity = DEFAULT_SPRINT_FOV_BOOST_INTENSITY
	toggle_sprint = DEFAULT_TOGGLE_SPRINT

	if save:
		_apply_settings()
		save_settings()


func reset_audio_settings(save: bool = true) -> void:
	master_volume = DEFAULT_MASTER_VOLUME
	sound_volume = DEFAULT_SOUND_VOLUME
	music_volume = DEFAULT_MUSIC_VOLUME

	if save:
		_apply_settings()
		save_settings()


func _apply_settings() -> void:
	DisplayServer.window_set_current_screen(monitor)
	DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_mode(window_mode)
	DisplayServer.window_set_vsync_mode(vsync)
	Engine.max_fps = fps_limit

	_set_bus_volume("Master", master_volume)
	_set_bus_volume("Sound", sound_volume)
	_set_bus_volume("Music", music_volume)

	mouse_sensitivity_changed.emit(mouse_sensitivity)
	fov_changed.emit(fov)
	camera_x_inverted_changed.emit(camera_x_inverted)
	camera_y_inverted_changed.emit(camera_y_inverted)
	head_bob_intensity_changed.emit(head_bob_intensity)
	sprint_fov_boost_intensity_changed.emit(sprint_fov_boost_intensity)
	toggle_sprint_changed.emit(toggle_sprint)


func set_resolution(value: Vector2i) -> void:
	windowed_resolution = value

	if window_mode == DisplayServer.WINDOW_MODE_WINDOWED:
		resolution = value
		DisplayServer.window_set_size(resolution)

	save_settings()


func set_window_mode(value: DisplayServer.WindowMode) -> void:
	if value == DisplayServer.WINDOW_MODE_WINDOWED and window_mode != DisplayServer.WINDOW_MODE_WINDOWED:
		window_mode = value
		resolution = windowed_resolution
		DisplayServer.window_set_mode(window_mode)
		DisplayServer.window_set_size(resolution)
	else:
		window_mode = value

		if value == DisplayServer.WINDOW_MODE_FULLSCREEN or value == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			var monitor_index: int = DisplayServer.window_get_current_screen()
			resolution = DisplayServer.screen_get_size(monitor_index)

		DisplayServer.window_set_mode(window_mode)

	save_settings()


func set_vsync(value: DisplayServer.VSyncMode) -> void:
	vsync = value
	DisplayServer.window_set_vsync_mode(vsync)
	save_settings()


func set_fps_limit(value: int) -> void:
	fps_limit = max(value, 0)
	Engine.max_fps = fps_limit
	save_settings()


func set_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = value
	mouse_sensitivity_changed.emit(value)
	save_settings()


func set_camera_x_inverted(value: bool) -> void:
	camera_x_inverted = value
	camera_x_inverted_changed.emit(value)
	save_settings()


func set_camera_y_inverted(value: bool) -> void:
	camera_y_inverted = value
	camera_y_inverted_changed.emit(value)
	save_settings()


func set_fov(value: float) -> void:
	fov = value
	fov_changed.emit(value)
	save_settings()


func set_head_bob_intensity(value: float) -> void:
	head_bob_intensity = clampf(value, 0.0, 100.0)
	head_bob_intensity_changed.emit(head_bob_intensity)
	save_settings()


func set_sprint_fov_boost_intensity(value: float) -> void:
	sprint_fov_boost_intensity = clampf(value, 0.0, 100.0)
	sprint_fov_boost_intensity_changed.emit(sprint_fov_boost_intensity)
	save_settings()

func set_toggle_sprint(value: bool) -> void:
	toggle_sprint = value
	toggle_sprint_changed.emit(toggle_sprint)
	save_settings()


func set_master_volume(value: float) -> void:
	master_volume = value
	_set_bus_volume("Master", value)
	save_settings()


func set_sound_volume(value: float) -> void:
	sound_volume = value
	_set_bus_volume("Sound", value)
	save_settings()


func set_music_volume(value: float) -> void:
	music_volume = value
	_set_bus_volume("Music", value)
	save_settings()


func set_monitor(value: int) -> void:
	monitor = clampi(value, 0, max(0, DisplayServer.get_screen_count() - 1))
	DisplayServer.window_set_current_screen(monitor)
	save_settings()

func _set_bus_volume(bus_name: String, volume: float) -> void:
	var bus_index: int = AudioServer.get_bus_index(bus_name)

	if bus_index >= 0:
		AudioServer.set_bus_volume_db(bus_index, SoundManager.volume_to_db(volume))
	else:
		push_error("Bus not found: " + bus_name)

func _capture_default_input_map() -> void:
	default_input_map.clear()
	default_keyboard_map.clear()
	default_gamepad_map.clear()

	for action: StringName in InputMap.get_actions():
		var events: Array[InputEvent] = InputMap.action_get_events(action)

		if events.is_empty():
			continue

		default_input_map[action] = events.duplicate()
		default_keyboard_map[action] = _filter_events(events, true)
		default_gamepad_map[action] = _filter_events(events, false)


static func _is_gamepad_event(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion


static func _filter_events(events: Array[InputEvent], keyboard: bool) -> Array[InputEvent]:
	var filtered: Array[InputEvent] = []

	for event: InputEvent in events:
		if _is_gamepad_event(event) != keyboard:
			filtered.append(event)

	return filtered


func save_input_map() -> void:
	save_settings()


func load_input_map() -> void:
	# Pre-device-profile saves: treat the old mixed section as keyboard bindings
	if settings_file.has_section(INPUT_SECTION_LEGACY):
		_load_input_section(INPUT_SECTION_LEGACY, true, true)
	elif settings_file.has_section(INPUT_SECTION_KEYBOARD) or settings_file.has_section(INPUT_SECTION_GAMEPAD):
		# Sections only exist when the profile differs from defaults
		if settings_file.has_section(INPUT_SECTION_KEYBOARD):
			_load_input_section(INPUT_SECTION_KEYBOARD, true)
		if settings_file.has_section(INPUT_SECTION_GAMEPAD):
			_load_input_section(INPUT_SECTION_GAMEPAD, false)


func _load_input_section(section: String, keyboard: bool, erase_all: bool = false) -> void:
	for action: String in settings_file.get_section_keys(section):
		if InputMap.has_action(action) == false:
			continue

		if erase_all:
			# Legacy saves store the complete event list, so replace it wholesale
			InputMap.action_erase_events(action)
		else:
			# Remove only the events belonging to this device's profile, so the
			# other device's bindings are left untouched
			for event: InputEvent in InputMap.action_get_events(action).duplicate():
				if _is_gamepad_event(event) != keyboard:
					InputMap.action_erase_event(action, event)

		var serialized_events: Array = settings_file.get_value(section, action, [])

		for event_dict: Dictionary in serialized_events:
			InputMap.action_add_event(action, _dict_to_event(event_dict))


func reset_input_map() -> void:
	for action: StringName in default_input_map.keys():
		InputMap.action_erase_events(action)

		for event: InputEvent in default_input_map[action]:
			InputMap.action_add_event(action, event)

	save_settings()


# Only writes actions whose events differ from the project defaults, saving a
# separate profile per device
func _write_input_map() -> void:
	_write_input_section(INPUT_SECTION_KEYBOARD, true)
	_write_input_section(INPUT_SECTION_GAMEPAD, false)


func _write_input_section(section: String, keyboard: bool) -> void:
	if settings_file.has_section(section):
		settings_file.erase_section(section)

	for action: StringName in default_input_map.keys():
		var current_events: Array[InputEvent] = InputMap.action_get_events(action)
		var device_events: Array[InputEvent] = _filter_events(current_events, keyboard)
		var default_events: Array[InputEvent] = default_keyboard_map.get(action, []) if keyboard else default_gamepad_map.get(action, [])

		if _events_equal(device_events, default_events):
			continue

		var serialized_events: Array = []

		for event: InputEvent in device_events:
			serialized_events.append(_event_to_dict(event))

		settings_file.set_value(section, action, serialized_events)


func _events_equal(a: Array[InputEvent], b: Array[InputEvent]) -> bool:
	if a.size() != b.size():
		return false

	for i in a.size():
		if _event_to_dict(a[i]) != _event_to_dict(b[i]):
			return false

	return true


static func _event_to_dict(event: InputEvent) -> Dictionary:
	var dict: Dictionary = {"type": event.get_class()}

	for property in event.get_property_list():
		if property["usage"] & PROPERTY_USAGE_STORAGE:
			dict[property["name"]] = event.get(property["name"])

	return dict


static func _dict_to_event(dict: Dictionary) -> InputEvent:
	var event: InputEvent = ClassDB.instantiate(dict["type"])

	for key: String in dict:
		if key == "type":
			continue

		event.set(key, dict[key])

	return event
