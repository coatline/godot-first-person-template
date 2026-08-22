class_name ActorStateMachine extends Node

var current_state: ActorState = null

# Not sure if this should be _physics_process or not
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func try_set_state(new_state: ActorState) -> void:
	# print("Trying to set %s state to %s" % [get_parent().name, new_state.name()])
	
	if current_state == new_state:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	
	if current_state:
		current_state.enter()
