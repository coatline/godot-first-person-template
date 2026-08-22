extends CharacterBody3D
class_name ActorBody

signal jumped
signal landed

@export var actor: Actor
@export var ground_raycast: RayCast3D
@export var stamina_component: StaminaComponent
@export var sprint_stamina_cost: float = 1.0

@export var jump_velocity = 8.0
@export var gravity: float = 19.6
@export var sprinting_movement_speed: float = 10.0
@export var walking_movement_speed: float = 5.0
@export var base_acceleration: float = 16.0
@export var push_force: float = 5.0
@export var sprint_jump_stamina_cost: float = 0.5
@export var slide_stamina_cost: float = 0.4

@export_category("Crouching")
@export var crouching_movement_speed: float = 2.0
@export var crouch_transition_speed = 8.0
@export var crouch_height = 0.5
@export var collision_shape : CollisionShape3D

@export_category("Sliding")
@export var slide_sound_player: AudioStreamPlayer3D
@export var slide_boost: float = 1
@export var slide_friction: float = 1.0
@export var slide_end_speed: float = 1.5
@export var slide_steer_acceleration: float = 1.5

var was_grounded_last_frame: bool
var current_gravity: float
var stand_height: float
var is_crouching: bool
var is_sprinting: bool
var is_sliding: bool

func _ready() -> void:
	current_gravity = gravity
	stand_height = collision_shape.shape.height
	stamina_component.stamina_depleted.connect(_on_stamina_depleted)
	was_grounded_last_frame = is_on_floor()

func _on_stamina_depleted() -> void:
	set_sprinting(false)

func do_crouch(delta: float, target_height: float):
	var transition_speed: float = crouch_transition_speed * delta 
	collision_shape.shape.height = lerp(collision_shape.shape.height, target_height, transition_speed)
	collision_shape.position.y = lerp(collision_shape.position.y, target_height * 0.5, transition_speed)

func try_jump() -> void:
	if ground_raycast.is_colliding():
		if is_sliding:
			cancel_slide()
		if is_sprinting:
			stamina_component.consume(sprint_jump_stamina_cost)
		velocity.y = jump_velocity
		jumped.emit()

func _physics_process(delta: float) -> void:
	velocity.y -= current_gravity * delta
	do_crouch(delta, crouch_height if is_crouching else stand_height)
	
	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
	
		if collider is RigidBody3D:
			var push_dir = -collision.get_normal()
			collider.apply_central_impulse(push_dir * push_force)
	
	if is_on_floor():
		if is_sprinting:
			stamina_component.consume(sprint_stamina_cost * delta)
	
		if is_sliding:
			var horizontal := Vector3(velocity.x, 0.0, velocity.z)
			var speed := horizontal.length()
			if speed <= slide_end_speed:
				cancel_slide()
			else:
				var slide_dir := horizontal.normalized()
				speed *= exp(-slide_friction * delta)
				velocity.x = slide_dir.x * speed
				velocity.z = slide_dir.z * speed
				var speed_factor: float = max((speed - slide_end_speed) / (sprinting_movement_speed), 0)
				slide_sound_player.volume_db = SoundManager.volume_to_db(speed_factor)
	elif is_sliding:
		cancel_slide()
	
	var last_frame = was_grounded_last_frame
	was_grounded_last_frame = is_on_floor()
	if last_frame == false && was_grounded_last_frame == true:
		landed.emit()

func set_sprinting(_value: bool):
	if _value == true and stamina_component.is_empty():
		return
	
	is_sprinting = _value
	
	if is_sprinting and is_crouching and not is_sliding:
		set_crouching(false)

func stop_moving():
	velocity = Vector3(0, velocity.y, 0)

func set_crouching(crouching: bool):
	if crouching == true and is_on_floor() == false:
		return
	
	is_crouching = crouching
	
	if is_crouching == true:
		if is_sprinting:
			set_sprinting(false)
		if get_horizontal_velocity().length() > walking_movement_speed * 1.5 and is_on_floor():
			start_slide()
	elif is_sliding:
		cancel_slide()

func start_slide() -> void:
	if is_sliding:
		return
	
	stamina_component.consume(slide_stamina_cost)
	is_sliding = true
	slide_sound_player.play()
	
	var horizontal_vel: Vector3 = get_horizontal_velocity()
	var slide_dir := horizontal_vel.normalized()
	velocity.x += slide_dir.x * slide_boost
	velocity.z += slide_dir.z * slide_boost

func cancel_slide() -> void:
	is_sliding = false
	slide_sound_player.stop()

func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0.0, velocity.z)

func _get_current_unscaled_movement_speed() -> float:
	var speed = walking_movement_speed
	
	if is_crouching:
		speed = crouching_movement_speed
	elif is_sprinting:
		speed = sprinting_movement_speed
	
	return speed
