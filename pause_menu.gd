extends UIMenu
class_name PauseMenu

@export var resume_button: Button
@export var settings_button: Button
@export var main_menu_button: Button
@export var save_button: Button
@export var load_button: Button

@export var settings_screen: SettingsScreen

func _ready() -> void:
	visible = false
	resume_button.pressed.connect(back)
	settings_button.pressed.connect(settings_screen.activate)
	main_menu_button.pressed.connect(to_main_menu)
	save_button.pressed.connect(_on_save_button_pressed)
	load_button.pressed.connect(_on_load_button_pressed)


func on_close() -> void:
	if UIMenuController.I.menu_stack.is_empty():
		get_tree().paused = false

func on_open() -> void:
	get_tree().paused = true

func to_main_menu() -> void:
	get_tree().paused = false
	SceneFader.change_scene_to_file("res://main_menu.tscn", SceneFader.TransitionAnimation.WIPE)

func _on_save_button_pressed():
	GameSaveManager.I.save_game()

func _on_load_button_pressed():
	GameSaveManager.I.load_game()
	close()

#func _process(delta: float) -> void:
	#var hovered: Control = get_viewport().gui_get_hovered_control()
#
	#if hovered:
		#print(hovered.name)
