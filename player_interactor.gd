extends Interactor
class_name PlayerInteractor

@export var interact_distance: float = 3.0
@export var keybinds_label: KeybindLabel
@export var raycast: RayCast3D

signal hover_changed(interactable: Interactable)

var hovered_object: Interactable = null

func _physics_process(delta):
	raycast.target_position = -raycast.transform.basis.z * interact_distance
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		var interactable: Interactable = null
	
		while collider:
			interactable = collider as Interactable
			if interactable:
				break
			collider = collider.get_parent()
		
		if interactable:
			if interactable.can_interact(self):
				if hovered_object != interactable:
					hovered_object = interactable
					hover_changed.emit(hovered_object)
				
				if Input.is_action_just_pressed("interact"):
					keybinds_label.hide_keybind("interact")
					try_interact_with(interactable)
				else:
					keybinds_label.show_keybind(interactable.interact_text(self), "interact")
				
				return
	
	_clear_hover()

func _clear_hover():
	if hovered_object:
		hovered_object = null
		hover_changed.emit(null)
	
	keybinds_label.hide_keybind("interact")
