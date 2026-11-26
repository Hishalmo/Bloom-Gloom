extends Node


var checkpoint:= Vector2(330,-800)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("E"):
		print("current checkpoint:",checkpoint)
