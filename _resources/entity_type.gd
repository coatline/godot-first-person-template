extends Resource
class_name EntityType

enum Team {
	PLAYER,
	ENEMY
}

@export var texture: Texture
@export var max_health: int
@export var name: String
@export var visual_scene: PackedScene
@export var death_animation_scene: PackedScene