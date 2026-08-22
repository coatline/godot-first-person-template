class_name ActorState extends RefCounted 

var actor: Actor
signal completed

func _init(_actor: Actor) -> void:
	actor = _actor

func enter() -> void:
	pass

func update(delta: float) -> void:
	pass

func exit():
	pass

func name():
	return get_script().get_global_name() + " (unnamed)"

var forced: bool = false
func get_skippable() -> bool: return true
func allows_movement() -> bool: return false
