extends TextureRect
class_name InteractionCrosshair

@export var interactor: PlayerInteractor
@export var hovered_scale: float = 1.4
@export var hovered_color: Color = Color(1.0, 0.85, 0.4, 1.0)
@export var ease_speed: float = 12.0
@export var stamina_bar: TextureProgressBar

var target_progress: float = 0.0
var hover_progress: float = 0.0

func _ready() -> void:
	if interactor:
		interactor.hover_changed.connect(_on_hover_changed)

func _on_hover_changed(interactable: Interactable) -> void:
	target_progress = 1.0 if interactable != null else 0.0

func _process(delta: float) -> void:
	hover_progress = lerpf(hover_progress, target_progress, min(delta * ease_speed, 1.0))
	scale = Vector2.ONE * lerpf(1.0, hovered_scale, hover_progress)
	modulate = Color(1, 1, 1, 1).lerp(hovered_color, hover_progress)
