extends UIMenu
class_name GameplaySettingsMenu

@export var mouse_sensitivity_h_slider: HSlider
@export var fov_h_slider: HSlider
@export var invert_mouse_y_checkbox: CheckBox
@export var invert_mouse_x_checkbox: CheckBox
@export var head_bob_intensity_h_slider: HSlider
@export var head_bob_intensity_label: Label
@export var sprint_fov_boost_h_slider: HSlider
@export var sprint_fov_boost_label: Label
@export var toggle_sprint_checkbox: CheckBox
@export var mouse_sensitivity_label: Label
@export var fov_label: Label
@export var reset_button: Button

func _ready() -> void:
	mouse_sensitivity_h_slider.value = SettingsSaveManager.mouse_sensitivity
	fov_h_slider.value = SettingsSaveManager.fov
	invert_mouse_y_checkbox.button_pressed = SettingsSaveManager.camera_y_inverted
	invert_mouse_x_checkbox.button_pressed = SettingsSaveManager.camera_x_inverted
	head_bob_intensity_h_slider.value = SettingsSaveManager.head_bob_intensity
	sprint_fov_boost_h_slider.value = SettingsSaveManager.sprint_fov_boost_intensity
	toggle_sprint_checkbox.button_pressed = SettingsSaveManager.toggle_sprint
	mouse_sensitivity_h_slider.value_changed.connect(_on_mouse_sensitivity_changed)
	fov_h_slider.value_changed.connect(_on_fov_changed)
	invert_mouse_y_checkbox.toggled.connect(_on_invert_mouse_y_toggled)
	invert_mouse_x_checkbox.toggled.connect(_on_invert_mouse_x_toggled)
	head_bob_intensity_h_slider.value_changed.connect(_on_head_bob_intensity_changed)
	sprint_fov_boost_h_slider.value_changed.connect(_on_sprint_fov_boost_intensity_changed)
	toggle_sprint_checkbox.toggled.connect(_on_toggle_sprint_toggled)
	reset_button.pressed.connect(_on_reset_pressed)
	fov_label.text = "FOV (%d)" % SettingsSaveManager.fov
	mouse_sensitivity_label.text = "Mouse Sensitivity (%.1f)" % SettingsSaveManager.mouse_sensitivity
	head_bob_intensity_label.text = "Head Bob Intensity (%.0f)" % SettingsSaveManager.head_bob_intensity
	sprint_fov_boost_label.text = "Sprint FOV Boost (%.0f)" % SettingsSaveManager.sprint_fov_boost_intensity

func _on_mouse_sensitivity_changed(value: float) -> void:
	SettingsSaveManager.set_mouse_sensitivity(value)
	mouse_sensitivity_label.text = "Mouse Sensitivity (%.1f)" % value

func _on_fov_changed(value: float) -> void:
	var actual: float = remap(value, 0, 100, 50, 100)
	SettingsSaveManager.set_fov(actual)
	fov_label.text = "FOV (%d)" % actual

func _on_invert_mouse_y_toggled(pressed: bool) -> void:
	SettingsSaveManager.set_camera_y_inverted(pressed)

func _on_invert_mouse_x_toggled(pressed: bool) -> void:
	SettingsSaveManager.set_camera_x_inverted(pressed)

func _on_head_bob_intensity_changed(value: float) -> void:
	SettingsSaveManager.set_head_bob_intensity(value)
	head_bob_intensity_label.text = "Head Bob Intensity (%.0f)" % value

func _on_sprint_fov_boost_intensity_changed(value: float) -> void:
	SettingsSaveManager.set_sprint_fov_boost_intensity(value)
	sprint_fov_boost_label.text = "Sprint FOV Boost (%.0f)" % value

func _on_toggle_sprint_toggled(pressed: bool) -> void:
	SettingsSaveManager.set_toggle_sprint(pressed)

func _on_reset_pressed() -> void:
	SettingsSaveManager.reset_gameplay_settings()
	mouse_sensitivity_h_slider.set_value_no_signal(SettingsSaveManager.mouse_sensitivity)
	fov_h_slider.set_value_no_signal(SettingsSaveManager.fov)
	invert_mouse_y_checkbox.set_pressed_no_signal(SettingsSaveManager.camera_y_inverted)
	invert_mouse_x_checkbox.set_pressed_no_signal(SettingsSaveManager.camera_x_inverted)
	head_bob_intensity_h_slider.set_value_no_signal(SettingsSaveManager.head_bob_intensity)
	head_bob_intensity_label.text = "Head Bob Intensity (%.0f)" % SettingsSaveManager.head_bob_intensity
	sprint_fov_boost_h_slider.set_value_no_signal(SettingsSaveManager.sprint_fov_boost_intensity)
	sprint_fov_boost_label.text = "Sprint FOV Boost (%.0f)" % SettingsSaveManager.sprint_fov_boost_intensity
	toggle_sprint_checkbox.set_pressed_no_signal(SettingsSaveManager.toggle_sprint)
	mouse_sensitivity_label.text = "Mouse Sensitivity (%.1f)" % SettingsSaveManager.mouse_sensitivity
	fov_label.text = "FOV (%d)" % SettingsSaveManager.fov
