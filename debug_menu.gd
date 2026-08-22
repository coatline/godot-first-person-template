extends Control

@export var time_speed_label: Label
@export var fps_label: Label
@export var time_of_day_label: Label

var paused_time_scale: float = 1.0
var disabled: bool

var _goap_status_label: Label

func _ready() -> void:
	TimeManager.I.time_scale_changed.connect(_on_time_scale_changed)
	_on_time_scale_changed(TimeManager.I.time_scale)

	_goap_status_label = Label.new()
	_goap_status_label.name = "GOAPStatusLabel"
	_goap_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_goap_status_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	_goap_status_label.add_theme_font_size_override("font_size", 10)
	add_child(_goap_status_label)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_debug"):
		disabled = !disabled
		visible = !disabled
	elif Input.is_action_just_pressed("release_mouse"):
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	
	if disabled:
		return

	if Input.is_action_just_pressed("DEBUG_pause_time"):
		if TimeManager.I.time_scale == 0:
			TimeManager.I.set_time_scale(paused_time_scale)
		else:
			paused_time_scale = TimeManager.I.time_scale
			TimeManager.I.set_time_scale(0.0)
	
	if Input.is_action_just_pressed("DEBUG_increment_time_small"):
		TimeManager.I.set_time_scale(TimeManager.I.time_scale + 0.1)
	elif Input.is_action_just_pressed("DEBUG_increment_time"):
		TimeManager.I.set_time_scale(TimeManager.I.time_scale + 1.0)
	elif Input.is_action_just_pressed("DEBUG_decrement_time_small"):
		TimeManager.I.set_time_scale(TimeManager.I.time_scale - 0.1)
	elif Input.is_action_just_pressed("DEBUG_decrement_time"):
		TimeManager.I.set_time_scale(TimeManager.I.time_scale - 1.0)
	
	if Input.is_action_just_pressed("DEBUG_reset"):
		get_tree().reload_current_scene()
	
	fps_label.text = "%sfps" % Engine.get_frames_per_second()
	time_of_day_label.text = TimeManager.I.get_time_string()

func _on_time_scale_changed(new_scale):
	time_speed_label.text = "%.1fx" % new_scale if new_scale != 0 else "Paused"
