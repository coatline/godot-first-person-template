extends CanvasLayer
@export var label: Label

func _ready() -> void:
	label.text = "v%s" % ProjectSettings.get_setting("application/config/version")
