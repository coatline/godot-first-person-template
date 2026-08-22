extends Node
class_name RegisteredObject

@export var type: ObjectType
@export var root: Node
## Unique ID for this object. If left blank, a new one will be generated.
@export var unique_id: String = ""

func _ready():
	if type == null:
		push_warning("Type not set on object %s! Not registering." % name)
		return
	
	if unique_id == "":
		unique_id = WorldRegistry.I.get_uuid(type.type_id)
	
	WorldRegistry.I.register_object(self)

func get_save_data() -> Dictionary:
	return {"type_id": type.type_id, "uuid": unique_id}

func load_save_data(save_data: Dictionary):
	unique_id = save_data["uuid"]
	WorldRegistry.I.register_object(self)
