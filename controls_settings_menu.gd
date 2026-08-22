extends UIMenu
class_name ControlsSettingsMenu

@export var controls_container: VBoxContainer
@export var standard_button_scene: PackedScene
@export var listening_label: Label
@export var reset_button: Button
@export var device_label: Label

const ACTIONS: Dictionary = {
	"move_forward": "Move Forward",
	"move_backward": "Move Backward",
	"move_left": "Move Left",
	"move_right": "Move Right",
	"jump": "Jump",
	"crouch": "Crouch",
	"interact": "Interact",
	"drop_item": "Drop Item",
	"use_item": "Use Item",
	"pause": "Pause",
}

const SLOT_PRIMARY := "primary"
const SLOT_SECONDARY := "secondary"
const SLOT_CLEAR := "clear"

var listening_action: String = ""
var listening_slot: String = ""

# True when the last captured input collided with the menu-close actions, so
# the menu controller knows not to close the menu for that same press
var _consumed_cancel: bool = false

# "action:slot" key of the button that should regain focus after a rebuild
var _focus_target: String = ""
var _slot_buttons: Dictionary = {}

func _ready() -> void:
	listening_label.hide()
	reset_button.pressed.connect(_on_reset_pressed)
	KeybindHelper.active_device_changed.connect(_on_device_changed)
	_update_device_label()
	_build_controls()

# The menu can't be closed by pause/cancel while a rebind is in progress
func can_close() -> bool:
	return listening_action.is_empty()

func close() -> void:
	# Rows are rebuilt while closed, so remember the focused slot by key
	# instead of the button reference
	_focus_target = _get_focus_target()
	super.close()

# Restore the last focused slot on open; the rows may have been rebuilt
func grab_focus_on_open() -> void:
	_apply_focus()

# Whether this menu consumed a menu-close input (bound it to a key) this
# frame. Consumes the flag and returns whether it was set.
func consume_cancel() -> bool:
	var was_consumed: bool = _consumed_cancel
	_consumed_cancel = false
	return was_consumed

# The bindings of the currently shown device, in order. The first is the
# primary input, the second (if any) is the secondary one.
func _get_device_events(action: String, keyboard: bool) -> Array:
	var device_events: Array = []

	for event: InputEvent in InputMap.action_get_events(action):
		if KeybindHelper.is_gamepad_event(event) == keyboard:
			continue
		device_events.append(event)

	return device_events

func _build_controls() -> void:
	_slot_buttons.clear()

	# Remove old rows from the tree immediately so they can't intercept focus
	# navigation or hover this frame (they're freed at frame end)
	for child: Node in controls_container.get_children():
		controls_container.remove_child(child)
		child.queue_free()

	var keyboard: bool = KeybindHelper.active_device == KeybindHelper.DEVICE_KEYBOARD
	var rows: Array[Dictionary] = []

	for action: String in ACTIONS:
		var device_events: Array = _get_device_events(action, keyboard)
		var primary_event: InputEvent = device_events[0] if not device_events.is_empty() else null
		var secondary_event: InputEvent = device_events[1] if device_events.size() > 1 else null

		var row: HBoxContainer = HBoxContainer.new()
		row.name = action

		var label: Label = Label.new()
		label.text = ACTIONS[action]
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(label)

		var primary_button: Button = _make_bind_button(primary_event, action, SLOT_PRIMARY)
		row.add_child(primary_button)

		var secondary_button: Button = _make_bind_button(secondary_event, action, SLOT_SECONDARY)
		row.add_child(secondary_button)

		# Clears the secondary binding for this action
		var clear_button: Button = standard_button_scene.instantiate()
		clear_button.text = "X"
		clear_button.custom_minimum_size = Vector2(40, 40)
		clear_button.disabled = secondary_event == null
		clear_button.pressed.connect(_clear_secondary.bind(action))
		row.add_child(clear_button)

		_slot_buttons[action + ":" + SLOT_CLEAR] = clear_button

		controls_container.add_child(row)

		rows.append({
			"primary": primary_button,
			"secondary": secondary_button,
			"clear": clear_button,
		})

	_assign_focus_neighbors(rows)

	_apply_focus()

func _make_bind_button(event: InputEvent, action: String, slot: String) -> Button:
	var button: Button = standard_button_scene.instantiate()
	button.text = _get_event_text(event) if event else "Unbound"
	button.custom_minimum_size = Vector2(120, 40)
	button.pressed.connect(_start_rebinding.bind(action, slot))
	_slot_buttons[action + ":" + slot] = button
	return button

# Explicit focus navigation: within a row, primary -> secondary -> clear;
# down jumps to the next row's primary, and the last row leads to reset
func _assign_focus_neighbors(rows: Array[Dictionary]) -> void:
	for i in rows.size():
		var primary: Control = rows[i]["primary"]
		var secondary: Control = rows[i]["secondary"]
		var clear: Control = rows[i]["clear"]

		var prev_primary: Control = rows[i - 1]["primary"] if i > 0 else primary
		var next_primary: Control = rows[i + 1]["primary"] if i + 1 < rows.size() else null

		primary.focus_neighbor_top = prev_primary.get_path()
		primary.focus_neighbor_bottom = next_primary.get_path() if next_primary else reset_button.get_path()
		primary.focus_neighbor_left = primary.get_path()
		primary.focus_neighbor_right = secondary.get_path()

		secondary.focus_neighbor_top = rows[i - 1]["secondary"].get_path() if i > 0 else secondary.get_path()
		secondary.focus_neighbor_bottom = next_primary.get_path() if next_primary else reset_button.get_path()
		secondary.focus_neighbor_left = primary.get_path()
		secondary.focus_neighbor_right = clear.get_path()

		clear.focus_neighbor_top = rows[i - 1]["clear"].get_path() if i > 0 else clear.get_path()
		clear.focus_neighbor_bottom = next_primary.get_path() if next_primary else reset_button.get_path()
		clear.focus_neighbor_left = secondary.get_path()
		clear.focus_neighbor_right = clear.get_path()

	if rows.is_empty():
		reset_button.focus_neighbor_top = reset_button.get_path()
	else:
		reset_button.focus_neighbor_top = rows[rows.size() - 1]["primary"].get_path()

	reset_button.focus_neighbor_bottom = reset_button.get_path()
	reset_button.focus_neighbor_left = reset_button.get_path()
	reset_button.focus_neighbor_right = reset_button.get_path()

# Give focus to the rebound button, or the first one otherwise, so the
# gamepad/keyboard can keep navigating after a rebuild
func _apply_focus() -> void:
	# Never grab focus while the menu is hidden: a device flip from a menu
	# open elsewhere (e.g. pausing) would steal that menu's focus
	if not is_visible_in_tree():
		return

	var target: Control = _slot_buttons.get(_focus_target, null)

	if target == null and not _slot_buttons.is_empty():
		target = _slot_buttons.values()[0]

	if target:
		target.grab_focus()

func _start_rebinding(action: String, slot: String) -> void:
	listening_action = action
	listening_slot = slot
	listening_label.text = "Press a key or button for %s (%s)... (B / Start to cancel)" % [
		ACTIONS[action],
		"primary" if slot == SLOT_PRIMARY else "secondary",
	]
	listening_label.show()

func _input(event: InputEvent) -> void:
	if listening_action.is_empty():
		return

	# Only bind presses (and held joypad axes); releases and echoes pass by.
	# JoypadMotion has no "pressed" property, so exclude it before checking.
	if not (event is InputEventJoypadMotion) and not event.pressed:
		return

	if event is InputEventJoypadMotion and absf(event.axis_value) <= 0.5:
		return

	if event is InputEventKey and event.echo:
		return

	# The dedicated cancel inputs (gamepad B / Start) abort the rebind. Keys
	# and mouse buttons are always bindable, including Escape.
	if event is InputEventJoypadButton:
		if InputMap.event_is_action(event, "ui_cancel") or InputMap.event_is_action(event, "pause"):
			listening_action = ""
			listening_slot = ""
			listening_label.hide()
			return

	if event is InputEventKey:
		_rebind_action(event)
	elif event is InputEventMouseButton:
		_rebind_action(event)
	elif event is InputEventJoypadButton:
		_rebind_action(event)
	elif event is InputEventJoypadMotion:
		var motion: InputEventJoypadMotion = event.duplicate()
		motion.axis_value = signf(motion.axis_value)
		_rebind_action(motion)

func _rebind_action(event: InputEvent) -> void:
	_focus_target = listening_action + ":" + listening_slot

	var keyboard: bool = not KeybindHelper.is_gamepad_event(event)
	var events: Array[InputEvent] = InputMap.action_get_events(listening_action).duplicate()

	if listening_slot == SLOT_SECONDARY:
		# Keep the primary binding, replace the secondary one (if any)
		var saw_primary: bool = false

		for existing: InputEvent in events:
			if KeybindHelper.is_gamepad_event(existing) == keyboard:
				continue
			if not saw_primary:
				saw_primary = true
				continue
			InputMap.action_erase_event(listening_action, existing)

		InputMap.action_add_event(listening_action, event)
	else:
# Override: replace every binding of the captured device
		for existing: InputEvent in events:
			if KeybindHelper.is_gamepad_event(existing) == keyboard:
				continue
			InputMap.action_erase_event(listening_action, existing)

		InputMap.action_add_event(listening_action, event)

	listening_action = ""
	listening_slot = ""
	listening_label.hide()

	# If the bound input is also a menu-close input (Escape = pause/ui_cancel),
	# tell the menu controller not to close the menu for this same press
	if InputMap.event_is_action(event, "ui_cancel") or InputMap.event_is_action(event, "pause"):
		_consumed_cancel = true

	_save_input_map()
	_build_controls()

func _clear_secondary(action: String) -> void:
	var keyboard: bool = KeybindHelper.active_device == KeybindHelper.DEVICE_KEYBOARD
	var saw_primary: bool = false

	for existing: InputEvent in InputMap.action_get_events(action).duplicate():
		if KeybindHelper.is_gamepad_event(existing) == keyboard:
			continue
		if not saw_primary:
			saw_primary = true
			continue
		InputMap.action_erase_event(action, existing)

	# Focus the secondary button so the player can bind a new one right away
	_focus_target = action + ":" + SLOT_SECONDARY
	_save_input_map()
	_build_controls()

func _get_event_text(event: InputEvent) -> String:
	if event is InputEventKey:
		# Events loaded from project.godot only have physical_keycode set,
		# while fresh press events populate keycode too.
		var keycode: Key = event.keycode
		if keycode == KEY_NONE:
			keycode = event.physical_keycode
		return OS.get_keycode_string(keycode)

	if event is InputEventMouseButton:
		return "Mouse %d" % event.button_index

	if event is InputEventJoypadButton:
		return KeybindHelper.get_joypad_button_name(event.button_index)

	if event is InputEventJoypadMotion:
		return KeybindHelper.get_joypad_axis_display(event)

	return "Unknown"

func _on_device_changed(_device: String) -> void:
	# Abort an in-progress rebind if the player switches devices
	if not listening_action.is_empty():
		listening_action = ""
		listening_slot = ""
		listening_label.hide()

	# Only capture the focused slot while this menu is on screen; otherwise
	# keep what was remembered from the last time it was open
	if is_visible_in_tree():
		_focus_target = _get_focus_target()
	_update_device_label()
	_build_controls()

func _get_focus_target() -> String:
	var focus_owner: Control = get_viewport().gui_get_focus_owner()

	if focus_owner == null:
		return ""

	for key: String in _slot_buttons:
		if _slot_buttons[key] == focus_owner:
			return key

	return ""

func _update_device_label() -> void:
	var keyboard: bool = KeybindHelper.active_device == KeybindHelper.DEVICE_KEYBOARD
	device_label.text = "Editing: Keyboard & Mouse" if keyboard else "Editing: Gamepad"

func _save_input_map() -> void:
	SettingsSaveManager.save_input_map()

func _on_reset_pressed() -> void:
	SettingsSaveManager.reset_input_map()
	_focus_target = ""
	_build_controls()
