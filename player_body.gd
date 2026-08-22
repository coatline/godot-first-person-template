extends ActorBody
class_name PlayerBody

@export var body_follow_speed = 5.0
@export var head: ActorHead

func do_crouch(delta: float, target_height: float):
	super(delta, target_height)
	head.position.y = lerp(head.position.y, target_height, crouch_transition_speed * delta)

func move_forward(input_dir: Vector2, delta: float):
	if not is_on_floor():
		return
	
	if is_sliding:
		if input_dir.length() > 0.1:
			var head_forward = head.global_transform.basis.z
			var move_dir = Vector3(head_forward.x, 0, head_forward.z).normalized()
			var final_dir = (move_dir * input_dir.y + head.global_transform.basis.x * input_dir.x).normalized()
			var horizontal := Vector3(velocity.x, 0.0, velocity.z)
			var speed := horizontal.length()
			velocity.x = lerp(velocity.x, final_dir.x * speed, slide_steer_acceleration * delta)
			velocity.z = lerp(velocity.z, final_dir.z * speed, slide_steer_acceleration * delta)
		return
	
	var move_speed = _get_current_unscaled_movement_speed()
	var head_forward = head.global_transform.basis.z
	var move_dir = Vector3(head_forward.x, 0, head_forward.z).normalized()
	var final_dir = (move_dir * input_dir.y + head.global_transform.basis.x * input_dir.x).normalized()
	
	velocity.x = lerp(velocity.x, final_dir.x * move_speed, base_acceleration * delta)
	velocity.z = lerp(velocity.z, final_dir.z * move_speed, base_acceleration * delta)
