extends Node


var checkpoint:= Vector2(20,-10)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("E"):
		print("current checkpoint:",checkpoint)
