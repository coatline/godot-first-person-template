extends Node
class_name UIMenuController

static var I: UIMenuController

@export var pause_menu: PauseMenu
@export var default_menu: UIMenu

var current_menu: UIMenu
var menu_stack: Array[UIMenu] = []

func _init() -> void:
	I = self

func _ready() -> void:
	# Keep handling pause/cancel input while the tree is paused by menus
	process_mode = Node.PROCESS_MODE_ALWAYS

	KeybindHelper.active_device_changed.connect(_on_device_changed)

	if default_menu:
		default_menu.open()

func _on_device_changed(_device: String) -> void:
	if current_menu:
		_update_mouse_for_device()

# Hide the cursor while a menu is open and the player is navigating with a
# gamepad, so the mouse hover doesn't fight with the focus indicator. Only
# called once when a menu opens, so it can't disrupt mid-navigation focus.
func _update_mouse_for_device() -> void:
	var using_gamepad: bool = KeybindHelper.active_device == KeybindHelper.DEVICE_GAMEPAD

	if using_gamepad:
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if current_menu:
			_handle_menu_close_input()
		elif pause_menu:
			push_menu(pause_menu)
	elif Input.is_action_just_pressed("ui_cancel"):
		if current_menu:
			_handle_menu_close_input()

func _handle_menu_close_input() -> void:
	# Skip closing if the menu consumed the input (e.g. Escape was just bound
	# to an action instead of closing the menu)
	if current_menu.consume_cancel():
		return

	if current_menu.can_close():
		current_menu.back()

func push_menu(menu: UIMenu) -> void:
	if current_menu == menu:
		return

	if current_menu:
		menu_stack.append(current_menu)
		current_menu.close()
	
	menu.show_menu()
	_update_mouse_for_device()

func pop_menu() -> void:
	var menu_to_close: UIMenu = current_menu
	var previous_menu: UIMenu = null

	if !menu_stack.is_empty():
		previous_menu = menu_stack.pop_back()

	if menu_to_close:
		menu_to_close.close()

	if previous_menu:
		previous_menu.show_menu()
	else:
		# If first person game:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func clear() -> void:
	if current_menu:
		current_menu.close()

	current_menu = null
	menu_stack.clear()

func menu_opened(menu: UIMenu) -> void:
	current_menu = menu

func menu_closed(menu: UIMenu) -> void:
	if menu == current_menu:
		current_menu = null
