extends Interactable
class_name HoldableObject

signal picked_up
signal left_hand
signal destroyed

@export var rb: RigidBody3D
@export var collider: CollisionShape3D
@export var display_name: String

var current_holder: ObjectHolder = null

func pickup(holder: ObjectHolder):
	collider.disabled = true
	rb.linear_velocity = Vector3.ZERO
	rb.angular_velocity = Vector3.ZERO

	rb.contact_monitor = false
	rb.gravity_scale = 0.0

	current_holder = holder
	picked_up.emit()

func drop(direction: Vector3, force: float):
	leave_hand()
	rb.linear_velocity = direction.normalized() * force

func leave_hand():
	remove_all_interactors()
	collider.disabled = false
	rb.contact_monitor = true
	rb.gravity_scale = 1.0
	
	current_holder = null
	left_hand.emit()
	remove_all_interactors()

func hold(pos: Vector3, rot: Vector3):
	rb.linear_velocity = Vector3.ZERO
	global_transform.origin = pos
	rotation_degrees = rot

func interact(interactor: Interactor) -> void:
	super(interactor)
	_force_add_interactor(interactor)
	interactor.object_holder.pickup(self)
	current_holder = interactor.object_holder

func can_interact(interactor: Interactor) -> bool:
	return not interactor.object_holder.has_item()

func use(direction: Vector3, delta: float, started: bool = false, finished: bool = false) -> void:
	pass

func _exit_tree():
	destroyed.emit()

func useable() -> bool: return false
func rotate_vertically() -> bool: return true
func text_color() -> Color: return Color.DARK_SALMON
func use_text() -> String: return Utils.get_verb_item_string("Use ", self)
func interact_text(interactor: Interactor) -> String: return Utils.get_verb_item_string("Pickup ", self)


func get_save_data() -> Dictionary:
	var save_data = super()
	save_data["linear_velocity"] = [rb.linear_velocity.x, rb.linear_velocity.y, rb.linear_velocity.z]
	return save_data

func load_save_data(save_data: Dictionary):
	super(save_data)
	var vel_arr = save_data["linear_velocity"]
	rb.linear_velocity = Vector3(vel_arr[0], vel_arr[1], vel_arr[2])
