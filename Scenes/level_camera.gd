extends Camera2D

func intro_pan(duration: float) -> void:
	var rest_position = global_position              # where the camera normally sits
	global_position = rest_position + Vector2(0, -600)   # start high up (tune this number)
	var t = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "global_position", rest_position, duration)
	await t.finished # the function waits here until the pan ends

func level_switch(target_position:Vector2):
	var t = create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "global_position", target_position, 0.5)
	
func _ready() -> void:
	intro_pan(18.0)
