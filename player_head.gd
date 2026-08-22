extends ActorHead
class_name PlayerHead

@export var navigation_obstacle: NavigationObstacle3D
@export var mouse_sensitivity = 0.5
@export var min_angle = -80
@export var max_angle = 90
@export var camera: Camera3D
@export var sprint_lean: float = 2.0
@export var slide_roll: float = 4.0
@export var gamepad_look_speed: float = 65.0

const SPRINT_FOV_BOOST: float = 20.0

var look_rot = Vector2.ZERO
var x_inverted = false
var y_inverted = false
var base_fov: float = 75.0
var current_fov: float = 75.0
var current_lean: float = 0.0
var current_roll: float = 0.0

func _ready():
	look_rot.y = rotation_degrees.y
	SettingsSaveManager.mouse_sensitivity_changed.connect(apply_mouse_sensitivity)
	SettingsSaveManager.fov_changed.connect(apply_fov)
	SettingsSaveManager.camera_y_inverted_changed.connect(apply_y_inverted)
	SettingsSaveManager.camera_x_inverted_changed.connect(apply_x_inverted)
	apply_mouse_sensitivity(SettingsSaveManager.mouse_sensitivity)
	apply_fov(SettingsSaveManager.fov)
	apply_x_inverted(SettingsSaveManager.camera_x_inverted)
	apply_y_inverted(SettingsSaveManager.camera_y_inverted)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		look_rot.y -= event.relative.x * mouse_sensitivity * 0.5 * (-1 if x_inverted else 1)
		look_rot.x -= event.relative.y * mouse_sensitivity * 0.5 * (-1 if y_inverted else 1)
		look_rot.x = clamp(look_rot.x, min_angle, max_angle)

func _physics_process(delta) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var stick := Vector2(Input.get_joy_axis(0, JOY_AXIS_RIGHT_X), Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y))
		if stick.length() > 0.15:
			look_rot.y -= stick.x * gamepad_look_speed * delta
			look_rot.x -= stick.y * gamepad_look_speed * delta * (-1 if y_inverted else 1)
			look_rot.x = clamp(look_rot.x, min_angle, max_angle)

	var horizontal_speed: float = Vector3(actor_body.velocity.x, 0.0, actor_body.velocity.z).length()
	var speed_boost_ratio: float = clampf((horizontal_speed - actor_body.walking_movement_speed) / (actor_body.sprinting_movement_speed - actor_body.walking_movement_speed), 0.0, 1.0)
	var target_lean: float = 0.0
	if speed_boost_ratio > 0.0 and not actor_body.is_sliding:
		target_lean = sprint_lean * 2.0 * speed_boost_ratio * (SettingsSaveManager.sprint_fov_boost_intensity / 100.0)
	current_lean = lerpf(current_lean, target_lean, delta * 8.0)
	var target_roll: float = 0.0
	if actor_body.is_sliding:
		var move_dir: Vector3 = actor_body.get_horizontal_velocity()
		if move_dir.length() > 0.5:
			move_dir = move_dir.normalized()
			var view_dir: Vector3 = -global_transform.basis.z
			view_dir.y = 0.0
			view_dir = view_dir.normalized()
			var signed_angle := atan2(view_dir.z * move_dir.x - view_dir.x * move_dir.z, view_dir.dot(move_dir))
			target_roll = slide_roll * (abs(signed_angle) / PI) * sign(signed_angle)
	current_roll = lerpf(current_roll, target_roll, delta * 8.0)
	rotation_degrees.x = look_rot.x + current_lean
	rotation_degrees.y = look_rot.y
	rotation_degrees.z = current_roll
	navigation_obstacle.rotation_degrees = Vector3(0, look_rot.y, 0)
	_update_fov(delta, speed_boost_ratio)

func apply_mouse_sensitivity(value: float) -> void:
	mouse_sensitivity = remap(value, 0, 100, 0.05, 1.0)

func apply_fov(value: float) -> void:
	base_fov = value
	current_fov = value
	camera.fov = value

func _update_fov(delta: float, speed_boost_ratio: float) -> void:
	var target_fov: float = base_fov
	target_fov += SPRINT_FOV_BOOST * speed_boost_ratio * (SettingsSaveManager.sprint_fov_boost_intensity / 100.0)
	current_fov = lerpf(current_fov, target_fov, delta * 8.0)
	camera.fov = current_fov

func apply_y_inverted(value: bool) -> void:
	y_inverted = value

func apply_x_inverted(value: bool) -> void:
	x_inverted = value
