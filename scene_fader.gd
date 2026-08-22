extends CanvasLayer

# SceneFader Autoload Singleton.
# Usage:
#   await SceneFader.change_scene_to_file("res://game.tscn")
#   SceneFader.change_scene_to_file("res://game.tscn", SceneFader.TransitionAnimation.CIRCLE)
#   SceneFader.change_scene_to_file("res://game.tscn", SceneFader.TransitionAnimation.SLIDE, 0.6)
# Patterns available: FADE, CIRCLE, SLIDE, WIPE

signal transition_finished(scene_path: String)

enum TransitionAnimation { FADE, CIRCLE, SLIDE, WIPE }

const DEFAULT_DURATION: float = 0.35

var is_transitioning: bool = false

@export var fade_rect: ColorRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 128
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reset_transition_state()

func change_scene_to_file(scene_path: String, animation: TransitionAnimation = TransitionAnimation.FADE, duration: float = DEFAULT_DURATION) -> void:
	if is_transitioning:
		return

	is_transitioning = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP

	await _run_animation(animation, true, duration * 0.5)
	get_tree().change_scene_to_file(scene_path)
	await _run_animation(animation, false, duration * 0.5)

	_reset_transition_state()
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false
	transition_finished.emit(scene_path)

# Covers the screen without changing scenes (e.g. fading out before quitting).
# Call fade_in() afterwards to uncover again.
func fade_out(animation: TransitionAnimation = TransitionAnimation.FADE, duration: float = DEFAULT_DURATION) -> void:
	if is_transitioning:
		return

	is_transitioning = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _run_animation(animation, true, duration * 0.5)

func fade_in(animation: TransitionAnimation = TransitionAnimation.FADE, duration: float = DEFAULT_DURATION) -> void:
	if not is_transitioning:
		return

	await _run_animation(animation, false, duration * 0.5)
	_reset_transition_state()
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	is_transitioning = false

func _run_animation(animation: TransitionAnimation, is_out: bool, time: float) -> void:
	var material: ShaderMaterial = fade_rect.material as ShaderMaterial
	var tween: Tween = create_tween()
	match animation:
		TransitionAnimation.FADE:
			tween.tween_property(material, "shader_parameter/fade_color:a", 1.0 if is_out else 0.0, time)
		TransitionAnimation.CIRCLE:
			tween.tween_property(material, "shader_parameter/radius", 1.0 if is_out else 0.0, time)
		TransitionAnimation.SLIDE:
			tween.tween_property(material, "shader_parameter/slide", 1.0 if is_out else 0.0, time)
		TransitionAnimation.WIPE:
			material.set_shader_parameter("wipe_reverse", not is_out)
			material.set_shader_parameter("wipe", 0.0)
			tween.tween_property(material, "shader_parameter/wipe", 1.02, time)
		_:
			push_warning("Unknown scene transition animation: %s" % animation)
			return
	await tween.finished

func _reset_transition_state() -> void:
	var material: ShaderMaterial = fade_rect.material as ShaderMaterial
	material.set_shader_parameter("fade_color", Color(0, 0, 0, 0))
	material.set_shader_parameter("radius", 0.0)
	material.set_shader_parameter("slide", 0.0)
	material.set_shader_parameter("wipe", 0.0)
	material.set_shader_parameter("wipe_reverse", false)
