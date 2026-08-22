class_name ActorIdleState extends ActorState

@export var friction: float = 10.0

func enter():
	pass
	
	#if actor.anim_player:
		#actor.anim_player.play("idle", 0.2)

func update(delta: float):
	pass
	# if actor is RigidBody3D:
	# 	var horizontal_vel = Vector3(actor.linear_velocity.x, 0, actor.linear_velocity.z)
	# 	if horizontal_vel.length() > 0.05:
	# 		var brake = horizontal_vel.move_toward(Vector3.ZERO, friction * delta)
	# 		actor.linear_velocity.x = brake.x
	# 		actor.linear_velocity.z = brake.z

func exit():
	pass

func name():
	return "IdleState"

func allows_movement() -> bool:
	return true
