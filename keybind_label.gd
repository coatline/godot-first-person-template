extends RichTextLabel
class_name KeybindLabel

var keys = {}

func _ready() -> void:
	KeybindHelper.active_device_changed.connect(_on_device_changed)

func _on_device_changed(_device: String) -> void:
	update_text()

func show_keybind(message: String, input_action: String) -> void:
	keys[input_action] = message
	update_text()

func hide_keybind(input_action: String) -> void:
	keys.erase(input_action)
	update_text()

func update_text():
	var key_index = 0
	text = ""

	# Recompute the keybind display every time so prompts follow the device
	# currently in use
	for action in keys:
		if key_index > 0:
			text += "\n"
		text += KeybindHelper.get_keybind_display(action) + ": " + keys[action]
		key_index += 1
