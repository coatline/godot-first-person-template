extends ActorBrain

@export var player_body: PlayerBody
@export var player_actor: Actor
@export var stamina_component: StaminaComponent

var move_state: PlayerMoveState
var sprint_toggled: bool = false

func _ready():
	move_state = PlayerMoveState.new(player_actor)
	player_actor.state_machine.try_set_state(move_state)
	stamina_component.stamina_depleted.connect(_stamina_depleted)

func _stamina_depleted():
	sprint_toggled = false

func _physics_process(delta):
	if paused:
		return

	if player_actor.state_machine.current_state.allows_movement():
		movement_inputs(delta)
		
		if Input.is_action_just_pressed("drop_item"):
			player_actor.object_holder.try_drop(5)
	elif Input.is_action_just_pressed("jump"):
		player_actor.state_machine.try_set_state(move_state)

func movement_inputs(delta):
	if Input.is_action_just_pressed("jump"):
		player_body.try_jump()
	
	_update_sprint()
	
	if Input.is_action_pressed("crouch"):
		player_body.set_crouching(true)
	elif Input.is_action_just_released("crouch"):
		player_body.set_crouching(false)
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	player_body.move_forward(input_dir, delta)

func _update_sprint() -> void:
	var use_toggle: bool = SettingsSaveManager.toggle_sprint

	if use_toggle:
		# Toggle sprint mode
		if Input.is_action_just_pressed("sprint"):
			sprint_toggled = not sprint_toggled

		# Releasing forward disarms the toggle, so sprinting doesn't resume on its
		# own the next time forward is pressed — but not while sliding, so a
		# slide+jump preserves the toggle
		if Input.is_action_just_released("move_forward") and not player_body.is_sliding:
			sprint_toggled = false

		# Sprinting (and stamina drain) only happens while actually moving forward
		var want_sprint: bool = sprint_toggled and Input.is_action_pressed("move_forward")
		if want_sprint and not player_body.is_sprinting and not player_body.is_sliding and not player_body.is_crouching:
			player_body.set_sprinting(true)
		elif not want_sprint and player_body.is_sprinting:
			player_body.set_sprinting(false)
	else:
		# Hold-to-sprint mode (original behavior)
		var want_sprint: bool = Input.is_action_pressed("sprint") and Input.is_action_pressed("move_forward")
		if want_sprint and not player_body.is_sprinting and not player_body.is_sliding and not player_body.is_crouching:
			player_body.set_sprinting(true)
		elif not want_sprint and player_body.is_sprinting:
			player_body.set_sprinting(false)
