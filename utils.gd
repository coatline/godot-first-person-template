class_name Utils
extends RefCounted

static func get_item_string(holdable_object: HoldableObject) -> String:
	return "[color=%s]%s[/color]" % [holdable_object.text_color().to_html(), holdable_object.display_name]

static func color_string(message: String, color: Color) -> String:
	return "[color=%s]%s[/color]" % [color.to_html(), message]

static func get_verb_item_string(message: String, holdable_object: HoldableObject) -> String:
	return "%s[color=%s]%s[/color]" % [message, holdable_object.text_color().to_html(), (holdable_object.display_name)]

static func apply_texture_to_face(face_mesh: MeshInstance3D, tex: Texture2D) -> void:
	var mat := get_new_material()
	mat.albedo_texture = tex
	face_mesh.set_surface_override_material(0, mat)

static func get_new_material() -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	mat.uv1_scale = Vector3.ONE
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return mat

static func get_closest_object(nodes: Array[Variant], requester_pos: Vector3) -> Variant:
	if nodes.is_empty():
		return null
	
	var closest_obj = null
	var min_dist = INF
	
	for node in nodes:
		# distance_squared_to is much faster than distance_to (no square root)
		var dist = requester_pos.distance_squared_to(node.global_position)
		if dist < min_dist:
			min_dist = dist
			closest_obj = node
		
	return closest_obj

static func calculate_decay_cost(base_cost: float, age: float, max_age_in_seconds: float, curve: float = 2.0) -> float:
	var life_ratio: float = clampf(1.0 - (age / max_age_in_seconds), 0.0, 1.0)
	return pow(life_ratio, curve) * base_cost

static func predict_need_change(current_val: float, hours: float, hours_to_empty: float, increase: bool = false) -> float:
	var change = hours / hours_to_empty
	if increase:
		return clampf(current_val + change, 0.0, 1.0)
	else:
		return clampf(current_val - change, 0.0, 1.0)

static func format_minutes(total_minutes: int) -> String:
	if total_minutes <= 0:
		return "0m"
	
	var d: = total_minutes / 1440
	var h = (total_minutes % 1440) / 60
	var m = total_minutes % 60
	
	var result = ""
	
	if d > 0:
		result += str(d) + "d "
	if h > 0:
		result += str(h) + "h "
	if m > 0 or result == "":
		result += str(m) + "m"
		
	return result.strip_edges()
