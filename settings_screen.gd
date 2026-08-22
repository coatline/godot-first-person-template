extends CanvasLayer
class_name SettingsScreen


@export var settings_home_menu: SettingsHomeMenu

func activate():
	settings_home_menu.open()

func _ready() -> void:
	for child in get_children():
		child.visible = false 
