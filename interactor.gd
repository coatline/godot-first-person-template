extends Node
class_name Interactor

@export var object_holder: ObjectHolder
@export var actor: Actor

var current_interactable: Interactable


func try_interact_with(new_interactable: Interactable) -> bool:
	if current_interactable == new_interactable:
		return false

	if new_interactable.can_interact(self) == false:
		return false
	
	try_stop_interacting()

	current_interactable = new_interactable
	new_interactable.interact(self)
	return true

func try_stop_interacting() -> void:
	if current_interactable == null:
		return
	
	var old_interactor = current_interactable
	
	current_interactable = null
	old_interactor.remove_interactor(self)
