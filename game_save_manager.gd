extends Node
class_name GameSaveManager

const SAVE_PATH = "user://savegame.json"
static var I: GameSaveManager

func _ready() -> void:
	I = self

func save_game():
	var save_data: SaveData = SaveData.new()
	var saveable_objects = get_tree().get_nodes_in_group("saveable")
	
	for saveable_object in saveable_objects:
		if saveable_object.has_method("get_save_data") == false:
			print("%s doesn't have a save method!" % saveable_object.name)
		
		var data: Dictionary = saveable_object.get_save_data()
		var type_id: String = data["type_id"]

		# If it has a uuid, we can assume it's a RegisteredObject.
		if data.has("uuid"):
			save_data.world_objects.append(data)
		elif type_id == "time":
			save_data.time = data
		else:
			print("Object %s doesn't have a uuid, skipping save." % saveable_object.name)
	
	var json_string = JSON.stringify(save_data.to_dictionary(), "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(json_string)
	print("Game Saved to: ", SAVE_PATH)

func load_game():
	if FileAccess.file_exists(SAVE_PATH) == false:
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json: Dictionary = JSON.parse_string(file.get_as_text())
	var save_data: SaveData = SaveData.new()
	save_data.load_from_json(json)

	WorldRegistry.I.delete_registered_objects()
	TimeManager.I.load_save_data(save_data.time)
	
	for obj_data in save_data.world_objects:
		spawn_from_save(obj_data)

func spawn_from_save(obj_data: Dictionary):
	var uuid: String = obj_data["uuid"]
	var instance = WorldRegistry.I.uuid_to_object.get(uuid, null)
	
	hydrate_json_memory(obj_data)
	
	if instance == null:
		var packed_scene: PackedScene = load(GameDataLoader.get_object_type_by_type_id(obj_data["type_id"]).packed_scene_uuid)
		instance = packed_scene.instantiate()
	else:
		print("Found existing instance for uuid: ", uuid)
	
	get_tree().current_scene.add_child(instance)
	instance.load_save_data(obj_data) # This sets the RegisteredObject's uuid before _ready can assign it a new one.
	return instance

static func hydrate_json_memory(data: Variant) -> Variant:
	if data is Dictionary:
		for key in data.keys():
			data[key] = hydrate_json_memory(data[key])
		return data
	elif data is Array:
		for i in range(data.size()):
			data[i] = hydrate_json_memory(data[i])
		return data
	elif data is String:
		if data.begins_with("(") and data.ends_with(")"):
			# Godot's str(Vector3) is "(x, y, z)"
			# str_to_var converts "(1, 2, 3)" back to a real Vector3
			var potential_vector = str_to_var("Vector3" + data)
			if potential_vector is Vector3:
				return potential_vector
		elif data == "null":
			return null
	
	return data

class SaveData:
	var world_objects: Array = []
	var time: Dictionary = {}

	func to_dictionary() -> Dictionary:
			return {"world_objects": world_objects, "time": time}
		
	func load_from_json(json: Dictionary):
		world_objects = json.get("world_objects", [])
		time = json.get("time", {})
