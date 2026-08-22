extends Node
class_name FootstepComponent

@export var actor_body: ActorBody
@export var step_distance: float = 2
@export var step_volume: float = 1.0
@export var ground_raycast: RayCast3D

var steps_accumulated: float = 0.0
var is_moving: bool

func _ready() -> void:
	actor_body.landed.connect(play_footstep_sound)
	actor_body.jumped.connect(play_footstep_sound)

func _handle_footsteps(delta: float) -> void:
	if actor_body.is_on_floor() == false or ground_raycast.is_colliding() == false or actor_body.is_sliding:
		return
	
	var speed = actor_body.velocity.length()
	steps_accumulated += speed * delta

	if speed <= 0.25:
		if is_moving == true:
			play_footstep_sound()
			is_moving = false
	else:
		is_moving = true

	if steps_accumulated < step_distance:
		return
	
	play_footstep_sound()

func _physics_process(delta: float) -> void:
	_handle_footsteps(delta)

func play_footstep_sound() -> void:
	steps_accumulated = 0.0
	await get_tree().process_frame
	SoundManager.play_sound(_get_surface_sound(), actor_body.global_position, 0.45 if actor_body.is_crouching else step_volume)

func _get_surface_sound() -> Sound:
	if ground_raycast.is_colliding():
		var collider: Object = ground_raycast.get_collider()
		return GameDataLoader.get_footstep_sound_of_surface(collider)
	return GameDataLoader.footstep_sounds["surface_default"]
