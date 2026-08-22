extends Node
class_name HeadBob

@export var actor_body: ActorBody
@export var head_node: Node3D
@export var amplitude: float = 0.1
@export var sway_amplitude: float = 0.04
@export var frequency: float = 11.0
@export var min_speed: float = 0.5
@export var smooth_speed: float = 8.0

var bob_time: float = 0.0
var starting_head_position: Vector3
var intensity_scale: float = 1.0
var bobbing: bool = false

func _ready() -> void:
	starting_head_position = head_node.position
	intensity_scale = SettingsSaveManager.head_bob_intensity / 100.0
	SettingsSaveManager.head_bob_intensity_changed.connect(func(value: float): intensity_scale = value / 100.0)

func get_bob_time() -> float:
	return bob_time

func is_bobbing() -> bool:
	return bobbing

func _physics_process(delta: float) -> void:
	var horizontal_velocity: Vector3 = Vector3(actor_body.velocity.x, 0.0, actor_body.velocity.z)
	var speed: float = horizontal_velocity.length()
	var moving: bool = intensity_scale > 0.0 and actor_body.is_on_floor() and speed > min_speed and not actor_body.is_sliding
	bobbing = moving
	
	var intensity: float = 0.0
	if moving:
		intensity = clampf(speed / actor_body.walking_movement_speed, 0.0, 1.5)
		bob_time += delta * frequency * intensity
	
	var target_position: Vector3 = starting_head_position
	if moving:
		var bob: float = sin(bob_time)
		var sway: float = cos(bob_time * 0.5)
		target_position += Vector3(sway * sway_amplitude, bob * amplitude, 0.0) * intensity * intensity_scale
	
	head_node.position = head_node.position.lerp(target_position, smooth_speed * delta)
