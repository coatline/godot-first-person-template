extends Control

@export var play_button: Button
@export var quit_button: Button

func _ready() -> void:
	play_button.pressed.connect(play)
	quit_button.pressed.connect(quit)
	play_button.grab_focus()

func play():
	SceneFader.change_scene_to_file("res://game.tscn", SceneFader.TransitionAnimation.CIRCLE)

func quit():
	await SceneFader.fade_out(SceneFader.TransitionAnimation.FADE, 0.5)
	get_tree().quit()
