extends Resource
class_name ObjectType

enum ObjectCategory {OBJECT, ACTOR}

@export var type_id: String
@export var name: String
@export var category: ObjectCategory
@export var packed_scene_uuid: String
