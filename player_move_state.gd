extends ActorState
class_name PlayerMoveState

func enter() -> void:
	pass

func update(delta: float) -> void:
	pass

func exit():
	actor.body.velocity = Vector3.ZERO
	pass

func allows_movement() -> bool: return true
