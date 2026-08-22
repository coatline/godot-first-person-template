extends Node
# KeybindHelper Autoload

const DEVICE_KEYBOARD: String = "keyboard"
const DEVICE_GAMEPAD: String = "gamepad"

signal active_device_changed(device: String)

# Last device the player actually used, so keybind prompts/UI follow them
var active_device: String = DEVICE_KEYBOARD

func _ready() -> void:
	# Keep detecting device switches while menus are open (tree may be paused)
	process_mode = Node.PROCESS_MODE_ALWAYS

	if not Input.get_connected_joypads().is_empty():
		active_device = DEVICE_GAMEPAD

func _input(event: InputEvent) -> void:
	var device: String = _event_device(event)

	if device != "" and device != active_device:
		active_device = device
		active_device_changed.emit(active_device)

static func is_gamepad_event(event: InputEvent) -> bool:
	return event is InputEventJoypadButton or event is InputEventJoypadMotion

func _event_device(event: InputEvent) -> String:
	if is_gamepad_event(event):
		return DEVICE_GAMEPAD

	if event is InputEventKey or event is InputEventMouseButton or event is InputEventMouseMotion:
		return DEVICE_KEYBOARD

	return ""

# Detect whether a gamepad is connected at all
func is_using_gamepad() -> bool:
	for device_id in Input.get_connected_joypads():
		if Input.is_joy_known(device_id):
			return true
	return false

# Get a display-friendly keybind string for an input action, following the
# device the player is currently using
func get_keybind_display(action_name: String) -> String:
	var events = InputMap.action_get_events(action_name)

	if events.is_empty():
		return "Unbound"

	var use_gamepad: bool = active_device == DEVICE_GAMEPAD

	for event in events:
		if use_gamepad and event is InputEventJoypadButton:
			return get_joypad_button_name(event.button_index)
		elif use_gamepad and event is InputEventJoypadMotion:
			return get_joypad_axis_display(event)
		elif not use_gamepad and event is InputEventKey:
			return OS.get_keycode_string(event.physical_keycode)
		elif not use_gamepad and event is InputEventMouseButton:
			return _get_mouse_button_name(event.button_index)

	return "Unknown"

# Converts a joypad button index to readable name
func get_joypad_button_name(button_index: int) -> String:
	match button_index:
		JOY_BUTTON_A: return "A"
		JOY_BUTTON_B: return "B"
		JOY_BUTTON_X: return "X"
		JOY_BUTTON_Y: return "Y"
		JOY_BUTTON_LEFT_SHOULDER: return "LB"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB"
		JOY_BUTTON_BACK: return "Back"
		JOY_BUTTON_START: return "Start"
		JOY_BUTTON_DPAD_UP: return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN: return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT: return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT: return "D-Pad Right"
		_: return "Button " + str(button_index)

func get_joypad_axis_display(event: InputEventJoypadMotion) -> String:
	var direction: String = "+" if event.axis_value > 0.0 else "-"
	return get_joypad_axis_name(event.axis) + " " + direction

# Converts a joypad axis to readable name
func get_joypad_axis_name(axis: JoyAxis) -> String:
	match axis:
		JOY_AXIS_LEFT_X: return "Left Stick X"
		JOY_AXIS_LEFT_Y: return "Left Stick Y"
		JOY_AXIS_RIGHT_X: return "Right Stick X"
		JOY_AXIS_RIGHT_Y: return "Right Stick Y"
		JOY_AXIS_TRIGGER_LEFT: return "Left Trigger"
		JOY_AXIS_TRIGGER_RIGHT: return "Right Trigger"
		_: return "Axis " + str(axis)

# Converts mouse buttons to readable names
func _get_mouse_button_name(button_index: int) -> String:
	match button_index:
		MOUSE_BUTTON_LEFT: return "LMB"
		MOUSE_BUTTON_RIGHT: return "RMB"
		MOUSE_BUTTON_MIDDLE: return "MMB"
		MOUSE_BUTTON_WHEEL_UP: return "Wheel Up"
		MOUSE_BUTTON_WHEEL_DOWN: return "Wheel Down"
		_: return "Mouse " + str(button_index)
