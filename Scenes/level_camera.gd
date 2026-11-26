extends Camera2D



func level_switch(target_position:Vector2):
	var t = create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "global_position", target_position, 0.5)
