extends Node3D
class_name ActorHead

@export var max_head_to_body_y_angle_difference = 60
@export var body_follow_speed = 5.0
@export var actor_body: ActorBody

func _body_follow_head(delta):
	var head_dir = global_transform.basis.z
	var body_dir = actor_body.global_transform.basis.z
	var angle_diff = rad_to_deg(body_dir.angle_to(Vector3(head_dir.x, 0, head_dir.z)))

	if angle_diff > max_head_to_body_y_angle_difference:
		var target_rot = Vector3(0, rotation_degrees.y, 0)
		actor_body.rotation_degrees.y = lerp_angle(rotation_degrees.y, target_rot.y, body_follow_speed * delta)
