extends Node
class_name Actor

@export var registered_object: RegisteredObject
@export var state_machine: ActorStateMachine
@export var object_holder: ObjectHolder
@export var animator: AnimationTree
@export var interactor: Interactor
@export var brain: ActorBrain
@export var body: ActorBody
@export var head: ActorHead

func play_anim(anim_name: String):
	if animator:
		var playback = animator.get("parameters/playback")
		playback.travel(anim_name)

var pos:
	get():
		return body.global_position
	set(val):
		body.velocity = Vector3.ZERO
		body.global_position = val 

func get_save_data() -> Dictionary:
	var dict = registered_object.get_save_data()
	dict["global_position"] = body.global_position
	dict["velocity"] = body.velocity
	dict["body_rotation"] = body.rotation_degrees
	dict["head_rotation"] = head.rotation_degrees
	return dict

func load_save_data(save_data: Dictionary):
	registered_object.load_save_data(save_data)
	
	body.global_position = save_data["global_position"]
	body.rotation_degrees = save_data["body_rotation"]
	head.rotation_degrees = save_data["head_rotation"]
	
	if head is PlayerHead:
		head.look_rot = head.rotation_degrees
	
	body.velocity = save_data["velocity"]
