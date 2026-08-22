extends Node
class_name SoundOnCollide

@export var sound: Sound
@export var rb: RigidBody3D
@export var max_impact_volume: float = 15

func _ready() -> void:
	rb.body_entered.connect(_body_entered)

func _body_entered(body) -> void:
	var state: PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(rb.get_rid())
	if state == null:
		return

	var impact: float = 0.0
	for i: int in state.get_contact_count():
		if instance_from_id(state.get_contact_collider_id(i)) != body:
			continue

		var impulse: Vector3 = state.get_contact_impulse(i)
		impact += abs(impulse.dot(state.get_contact_local_normal(i)))

	SoundManager.play_sound(sound, rb.global_position, clampf(impact / max_impact_volume, 0.0, 1.0))
