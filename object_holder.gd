extends Node3D
class_name ObjectHolder

@export var hand: Node3D
@export var drop_sound: Sound
@export var pick_up_sound: Sound
@export var actor_body: ActorBody
@export var head_bob: HeadBob
@export var sway_amount: float = 0.03
@export var sway_rotation_amount: float = 2.0
@export var bob_amount: float = 0.02

var holdable_object: HoldableObject = null

var sway_offset: Vector3 = Vector3.ZERO
var sway_rotation: Vector3 = Vector3.ZERO
var look_velocity: float = 0.0
var last_yaw: float = 0.0

func pickup(obj):
	holdable_object = obj
	holdable_object.pickup(self)
	
	holdable_object.left_hand.connect(object_gone)
	holdable_object.destroyed.connect(object_gone)
	SoundManager.play_sound(pick_up_sound, global_position)

func object_gone():
	if holdable_object:
		holdable_object.left_hand.disconnect(object_gone)
		holdable_object.destroyed.disconnect(object_gone)
		holdable_object = null

func try_drop(force: float):
	if holdable_object:
		holdable_object.drop(-global_transform.basis.z, force)
		SoundManager.play_sound(drop_sound, global_position)

func try_use(delta: float, started: bool = false, finished: bool = false) -> void:
	if holdable_object:
		holdable_object.use(-global_transform.basis.z, delta, started, finished)

func _physics_process(delta):
	if holdable_object:
		var rot_x = 0
		if holdable_object.rotate_vertically:
			rot_x = hand.global_rotation_degrees.x
		var rot = Vector3(rot_x, hand.global_rotation_degrees.y, hand.global_rotation_degrees.z)
		holdable_object.hold(hand.global_transform.origin + _get_sway_offset(delta), rot + _get_sway_rotation(delta))

func _get_sway_offset(delta: float) -> Vector3:
	var target: Vector3 = Vector3.ZERO
	if actor_body != null:
		var velocity: Vector3 = actor_body.velocity
		var lateral: float = clampf(velocity.dot(hand.global_transform.basis.x) / 10.0, -1.0, 1.0)
		var forward: float = clampf(velocity.dot(-hand.global_transform.basis.z) / 10.0, -1.0, 1.0)
		var bob: float = 0.0
		if head_bob != null and head_bob.is_bobbing():
			bob = sin(head_bob.get_bob_time()) * bob_amount
		target = Vector3(lateral * sway_amount, bob, -forward * sway_amount * 0.5)
	sway_offset = sway_offset.lerp(target, min(delta * 10.0, 1.0))
	return hand.global_transform.basis * sway_offset

func _get_sway_rotation(delta: float) -> Vector3:
	var target: Vector3 = Vector3.ZERO
	if actor_body != null:
		var yaw: float = hand.global_rotation_degrees.y
		var yaw_delta: float = wrapf(yaw - last_yaw, -180.0, 180.0)
		last_yaw = yaw
		look_velocity = lerpf(look_velocity, yaw_delta / max(delta, 0.001), 0.2)
		target.z = clampf(look_velocity / 300.0, -1.0, 1.0) * sway_rotation_amount
		var forward: float = clampf(actor_body.velocity.dot(-hand.global_transform.basis.z) / 10.0, -1.0, 1.0)
		target.x = forward * sway_rotation_amount * 0.3
	sway_rotation = sway_rotation.lerp(target, min(delta * 8.0, 1.0))
	return sway_rotation

func has_item() -> bool: return holdable_object != null
