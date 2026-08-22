extends TextureProgressBar
class_name StaminaBar

@export var stamina_component: StaminaComponent
@export var remnant_bar: TextureProgressBar
@export var remnant_drain_speed: float = 15.0

var remnant_value: float = 100.0
var prev_stamina: float
var frame: int

func _ready() -> void:
	remnant_bar.value = remnant_value

func _process(delta: float) -> void:
	var current := stamina_component.get_percent() * 100
	value = current

	if remnant_value > current:
		if current >= prev_stamina:
			remnant_value = max(remnant_value - remnant_drain_speed * delta * (remnant_value - current) * 0.1, current)
	else:
		remnant_value = current
	remnant_bar.value = remnant_value
