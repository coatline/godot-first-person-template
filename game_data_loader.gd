extends Node

var sound_dict: Dictionary[String, Sound]

var type_id_to_type: Dictionary[String, ObjectType]

var footstep_sounds: Dictionary

func get_sound(name: String):
	return sound_dict[name]

func get_object_type_by_type_id(id: String) -> ObjectType:
	return type_id_to_type[id]

func get_footstep_sound_of_surface(node: Node) -> Sound:
	for group in node.get_groups():
		if group in footstep_sounds:
			return footstep_sounds[group]
	return footstep_sounds["surface_default"]


func _init() -> void:
	var objects_group: ResourceGroup = preload("uid://bewto2e0tmy8i")
	var object_types: Array[ObjectType] = []
	objects_group.load_all_into(object_types)

	var sounds_group: ResourceGroup = preload("uid://c4gre0hbd7ild")
	var sounds: Array[Sound] = []
	sounds_group.load_all_into(sounds)
	
	for sound in sounds:
		sound_dict[sound.name] = sound
	
	for type in object_types:
		type_id_to_type[type.type_id] = type
	
	footstep_sounds = {
		"surface_grass": sound_dict["grass_footstep"],
		"surface_stone": sound_dict["stone_footstep"],
		#"Wood": sound_dict["wood_footstep"],
		"surface_default": sound_dict["stone_footstep"]
}
