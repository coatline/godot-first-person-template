extends Node
class_name ActorBrain

var paused

func pause_thinking():
	paused = true

func resume_thinking():
	paused = false
