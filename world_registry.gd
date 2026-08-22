extends Node
class_name WorldRegistry

static var I: WorldRegistry

var uuid_to_object: Dictionary[String, RegisteredObject]
var type_id_to_objects: Dictionary[String, Array]

func _ready():
	I = self

func delete_registered_objects():
	type_id_to_objects.clear()
	for obj_id in uuid_to_object.keys():
		uuid_to_object[obj_id].root.queue_free()
	
	uuid_to_object.clear()


func register_object(obj: RegisteredObject):
	uuid_to_object[obj.unique_id] = obj
	
	if type_id_to_objects.has(obj.type.type_id) == false:
		type_id_to_objects[obj.type.type_id] = []
	
	type_id_to_objects[obj.type.type_id].append(obj)

func get_uuid(prefix: String = "") -> String:
	var time = Time.get_ticks_usec()
	var random = randi()
	return "%s_%d_%d" % [prefix, time, random]

func get_closest_object_of_type(type_id: String, requester_pos: Vector3) -> RegisteredObject:
	if type_id_to_objects.has(type_id) == false or type_id_to_objects[type_id].is_empty():
		return null
	
	return Utils.get_closest_object(type_id_to_objects[type_id], requester_pos)

func get_random_object(type: Variant) -> Variant:
	var array = uuid_to_object.get(type)
	if array and not array.is_empty():
		return array.pick_random()
	return null

func spawn_node(scene: PackedScene, position: Vector3) -> Node:
	var instance = scene.instantiate()
	get_tree().current_scene.add_child(instance)
	instance.global_position = position
	
	return instance
