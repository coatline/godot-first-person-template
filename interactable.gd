extends Node3D
class_name Interactable

@export var _interact_point: Node3D
@export var registered_object: RegisteredObject

var current_interactors: Array[Interactor] = []


func interact(interactor: Interactor):
	pass

func _force_add_interactor(interactor: Interactor):
	if current_interactors.has(interactor):
		print("%s already contains %s", name, interactor.actor.name)
		return

	if current_interactors.size() >= max_users():
		prints("kicking out %s out of %s", current_interactors[0].actor.name, name)
		current_interactors[0].try_stop_interacting()
	
	current_interactors.append(interactor)

func is_actor_using(actor: Actor) -> bool:
	for interactor in current_interactors:
		if interactor.actor == actor:
			return true
	return false

func get_all_users() -> Array[ActorBody]:
	var users: Array[ActorBody] = []
	for interactor in current_interactors:
		users.append(interactor.actor.body)
	return users

func remove_all_interactors():
	for interactor in current_interactors:
		interactor.try_stop_interacting()
	current_interactors.clear()

func remove_interactor(interactor: Interactor):
	interactor.try_stop_interacting()
	current_interactors.erase(interactor)

func max_users() -> int: return 1
func can_force_kick_interactors() -> bool: return false
func interact_text(interactor: Interactor) -> String: return "Interact"
func can_interact(interactor: Interactor) -> bool: return current_interactors.size() < max_users() or can_force_kick_interactors()

func is_at_max_users() -> bool: return current_interactors.size() >= max_users()
func get_interact_position() -> Vector3:
	return _interact_point.global_position if _interact_point else global_position

func get_save_data() -> Dictionary:
	var registered_object_save_data = registered_object.get_save_data()
	registered_object_save_data["global_position"] = [global_position.x, global_position.y, global_position.z]
	return registered_object_save_data

func load_save_data(save_data: Dictionary):
	registered_object.load_save_data(save_data)
	
	var pos_arr = save_data["global_position"]
	global_position = Vector3(pos_arr[0], pos_arr[1], pos_arr[2])
