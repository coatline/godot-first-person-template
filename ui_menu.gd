extends Control
class_name UIMenu

signal opened(menu: UIMenu)
signal closed(menu: UIMenu)

# Button that had focus when the menu last closed, so reopening restores it
var _last_focus: Control = null

func open() -> void:
	UIMenuController.I.push_menu(self)

func show_menu() -> void:
	visible = true
	on_open()
	grab_focus_on_open()
	call_deferred("_ensure_focus")
	opened.emit(self)
	UIMenuController.I.menu_opened(self)

# Re-grab focus at the end of the frame if something (e.g. a mouse-mode change
# while opening the menu) cleared it, without fighting the player's navigation
func _ensure_focus() -> void:
	if not get_viewport().gui_get_focus_owner():
		grab_focus_on_open()

func close() -> void:
	_last_focus = get_viewport().gui_get_focus_owner()
	on_close()
	visible = false
	closed.emit(self)
	UIMenuController.I.menu_closed(self)

func back() -> void:
	UIMenuController.I.pop_menu()

# Whether the menu can be closed by pause/cancel input. Overridden by menus
# that are busy (e.g. mid-rebind).
func can_close() -> bool:
	return true

# Whether this menu consumed a menu-close input this frame (e.g. bound it to
# a key). Overridden by menus that capture such inputs.
func consume_cancel() -> bool:
	return false

func on_open() -> void:
	pass

func on_close() -> void:
	pass

# Focus the last focused button if it's still valid, otherwise the first
# focusable control, so the keyboard/gamepad can keep navigating
func grab_focus_on_open() -> void:
	if _last_focus and is_instance_valid(_last_focus) and _last_focus.is_visible_in_tree() and _last_focus.focus_mode != Control.FOCUS_NONE:
		_last_focus.grab_focus()
		return

	var control := _find_focusable_control(self)

	if control:
		control.grab_focus()

func _find_focusable_control(node: Node) -> Control:
	for child: Node in node.get_children():
		if child is Control and child.focus_mode == FocusMode.FOCUS_ALL:
			return child

		var found := _find_focusable_control(child)

		if found:
			return found

	return null
