extends UIMenu
class_name DisplaySettingsMenu

@export var resolution_dropdown: OptionButton
@export var window_mode_dropdown: OptionButton
@export var monitor_dropdown: OptionButton
@export var fps_limit_dropdown: OptionButton
@export var reset_button: Button

const RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1280, 800),
	Vector2i(1366, 768),
	Vector2i(1440, 900),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(1920, 1200),
	Vector2i(2560, 1080),
	Vector2i(2560, 1440),
	Vector2i(2560, 1600),
	Vector2i(3440, 1440),
	Vector2i(3840, 2160)
]

const WINDOW_MODES: Array[DisplayServer.WindowMode] = [
	DisplayServer.WINDOW_MODE_WINDOWED,
	DisplayServer.WINDOW_MODE_FULLSCREEN,
	DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN,
	DisplayServer.WINDOW_MODE_MAXIMIZED
]

const FPS_LIMITS: Array[int] = [0, 30, 60, 120, 144, 165, 240, 360]

var available_resolutions: Array[Vector2i] = []
var last_monitor: int = -1

func _ready() -> void:
	_populate_window_modes()
	_populate_monitors()
	_populate_fps_limits()
	_update_resolution_list()
	_select_current_window_mode()
	_select_current_monitor()
	_select_current_fps_limit()
	_update_resolution_dropdown_state()
	resolution_dropdown.item_selected.connect(_on_resolution_selected)
	window_mode_dropdown.item_selected.connect(_on_window_mode_selected)
	monitor_dropdown.item_selected.connect(_on_monitor_selected)
	fps_limit_dropdown.item_selected.connect(_on_fps_limit_selected)
	reset_button.pressed.connect(_on_reset_pressed)

func _process(_delta: float) -> void:
	var current_monitor: int = DisplayServer.window_get_current_screen()
	if current_monitor != last_monitor:
		last_monitor = current_monitor
		SettingsSaveManager.monitor = current_monitor
		monitor_dropdown.select(current_monitor)
		_update_resolution_list()

func _populate_window_modes() -> void:
	window_mode_dropdown.clear()
	window_mode_dropdown.add_item("Windowed")
	window_mode_dropdown.add_item("Fullscreen")
	window_mode_dropdown.add_item("Exclusive Fullscreen")
	window_mode_dropdown.add_item("Maximized")

func _populate_monitors() -> void:
	monitor_dropdown.clear()
	var monitor_count: int = DisplayServer.get_screen_count()
	for i: int in monitor_count:
		var refresh_rate: float = DisplayServer.screen_get_refresh_rate(i)
		monitor_dropdown.add_item("Monitor %d - %.0f Hz" % [i + 1, refresh_rate])

func _populate_fps_limits() -> void:
	fps_limit_dropdown.clear()
	for fps: int in FPS_LIMITS:
		if fps == 0:
			fps_limit_dropdown.add_item("Unlimited")
		else:
			fps_limit_dropdown.add_item("%d FPS" % fps)

func _update_resolution_list() -> void:
	available_resolutions.clear()
	resolution_dropdown.clear()

	var monitor: int = DisplayServer.window_get_current_screen()
	var monitor_size: Vector2i = DisplayServer.screen_get_size(monitor)
	var monitor_aspect_ratio: float = float(monitor_size.x) / float(monitor_size.y)

	for resolution: Vector2i in RESOLUTIONS:
		if resolution.x > monitor_size.x or resolution.y > monitor_size.y:
			continue

		var resolution_aspect_ratio: float = float(resolution.x) / float(resolution.y)

		if abs(resolution_aspect_ratio - monitor_aspect_ratio) > 0.02:
			continue

		if not available_resolutions.has(resolution):
			available_resolutions.append(resolution)

	if not available_resolutions.has(monitor_size):
		available_resolutions.append(monitor_size)

	available_resolutions.sort_custom(_sort_resolutions)

	for resolution: Vector2i in available_resolutions:
		resolution_dropdown.add_item("%d × %d" % [resolution.x, resolution.y])

	_select_current_resolution()

func _sort_resolutions(a: Vector2i, b: Vector2i) -> bool:
	return a.x * a.y < b.x * b.y

func _select_current_resolution() -> void:
	var current_resolution: Vector2i = SettingsSaveManager.resolution
	var closest_index: int = 0
	var closest_distance: int = INF

	for i: int in available_resolutions.size():
		var distance: int = abs(available_resolutions[i].x - current_resolution.x) + abs(available_resolutions[i].y - current_resolution.y)
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i

	if available_resolutions.size() > 0:
		resolution_dropdown.select(closest_index)

func _select_current_window_mode() -> void:
	var current_mode: DisplayServer.WindowMode = SettingsSaveManager.window_mode
	var index: int = WINDOW_MODES.find(current_mode)
	if index >= 0:
		window_mode_dropdown.select(index)

func _select_current_monitor() -> void:
	var monitor_count: int = DisplayServer.get_screen_count()
	if monitor_count <= 0:
		return

	var monitor: int = clampi(DisplayServer.window_get_current_screen(), 0, monitor_count - 1)
	monitor_dropdown.select(monitor)
	last_monitor = monitor

func _select_current_fps_limit() -> void:
	var index: int = FPS_LIMITS.find(SettingsSaveManager.fps_limit)
	if index >= 0:
		fps_limit_dropdown.select(index)

func _update_resolution_dropdown_state() -> void:
	var mode: DisplayServer.WindowMode = SettingsSaveManager.window_mode
	resolution_dropdown.disabled = mode != DisplayServer.WINDOW_MODE_WINDOWED

func _on_resolution_selected(index: int) -> void:
	if index >= 0 and index < available_resolutions.size():
		SettingsSaveManager.set_resolution(available_resolutions[index])

func _on_window_mode_selected(index: int) -> void:
	SettingsSaveManager.set_window_mode(WINDOW_MODES[index])
	_update_resolution_dropdown_state()

func _on_monitor_selected(index: int) -> void:
	SettingsSaveManager.set_monitor(index)
	last_monitor = index
	_update_resolution_list()
	_update_resolution_dropdown_state()

func _on_fps_limit_selected(index: int) -> void:
	if index >= 0 and index < FPS_LIMITS.size():
		SettingsSaveManager.set_fps_limit(FPS_LIMITS[index])

func _on_reset_pressed() -> void:
	SettingsSaveManager.reset_display_settings()
	_update_resolution_list()
	_select_current_window_mode()
	_select_current_monitor()
	_select_current_fps_limit()
	_update_resolution_dropdown_state()
