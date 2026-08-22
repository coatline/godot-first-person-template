extends Node
class_name CameraShake

static var I: CameraShake

@export var target: Node3D
@export var max_offset: float = 0.15
@export var max_rotation: float = 5.0

var shakes: Array[ShakeData] = []

var _base_position: Vector3
var _base_rotation: Vector3

func _init() -> void:
	I = self

func _ready() -> void:
	if target == null:
		target = get_parent() as Node3D
	_base_position = target.position
	_base_rotation = target.rotation_degrees

func _physics_process(delta: float) -> void:
	var position_offset := Vector3.ZERO
	var rotation_offset := Vector3.ZERO

	for shake in shakes:
		shake.time += delta
		if shake.time >= shake.duration:
			shake.active = false
			continue
		var falloff: float = pow(1.0 - shake.time / shake.duration, shake.falloff_exponent)
		var phase: float = shake.time * shake.frequency * TAU
		position_offset += Vector3(
			sin(phase + shake.phase_x),
			sin(phase * 1.2 + shake.phase_y),
			sin(phase * 0.8 + shake.phase_z) * 0.5
		) * shake.amplitude * falloff * max_offset
		rotation_offset += Vector3(
			sin(phase + shake.phase_y),
			sin(phase * 1.1 + shake.phase_z) * 0.6,
			sin(phase * 0.9 + shake.phase_x) * 0.3
		) * shake.amplitude * falloff * max_rotation

	shakes = shakes.filter(func(shake: ShakeData) -> bool: return shake.active)

	target.position = _base_position + position_offset
	target.rotation_degrees = _base_rotation + rotation_offset

func add_shake(amplitude: float = 0.5, frequency: float = 0.5, duration: float = 0.5, falloff_exponent: float = 2) -> void:
	shakes.append(ShakeData.new(amplitude, frequency, duration, falloff_exponent))

func is_shaking() -> bool:
	return not shakes.is_empty()

func reset() -> void:
	shakes.clear()
	target.position = _base_position
	target.rotation_degrees = _base_rotation

class ShakeData:
	var duration: float
	var frequency: float
	var amplitude: float
	var falloff_exponent: float
	var time: float = 0.0
	var active: bool = true
	var phase_x: float
	var phase_y: float
	var phase_z: float

	func _init(_amplitude: float, _frequency: float, _duration: float, _falloff_exponent: float) -> void:
		amplitude = _amplitude
		frequency = _frequency
		duration = max(_duration, 0.05)
		falloff_exponent = _falloff_exponent
		phase_x = randf() * TAU
		phase_y = randf() * TAU
		phase_z = randf() * TAU
