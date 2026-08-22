extends Node
class_name StaminaComponent

@export var max_stamina: float = 2.5
@export var regen_delay: float = 0.75
@export var regen_time: float = 1.0

var stamina: float
var regen_timer: float = 0.0

signal stamina_changed(value: float)
signal stamina_depleted
signal stamina_full

func _ready() -> void:
	stamina = max_stamina

func _process(delta: float) -> void:
	if regen_timer > 0.0:
		regen_timer -= delta
		return

	if stamina < max_stamina:
		stamina = move_toward(stamina, max_stamina, max_stamina / regen_time * delta)
		stamina_changed.emit(stamina)

		if stamina >= max_stamina:
			stamina_full.emit()

func consume(amount: float) -> bool:
	if stamina <= 0.0:
		return false

	stamina = max(stamina - amount, 0.0)
	regen_timer = regen_delay
	stamina_changed.emit(stamina)

	if stamina <= 0.0:
		stamina_depleted.emit()

	return true

func restore(amount: float) -> void:
	stamina = min(stamina + amount, max_stamina)
	regen_timer = regen_delay
	stamina_changed.emit(stamina)

func restore_full() -> void:
	stamina = max_stamina
	regen_timer = 0.0
	stamina_changed.emit(stamina)
	stamina_full.emit()

func is_empty() -> bool:
	return stamina <= 0.0

func is_full() -> bool:
	return stamina >= max_stamina

func get_percent() -> float:
	return stamina / max_stamina
