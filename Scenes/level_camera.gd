extends Camera2D


func intro_pan(duration: float) -> void:
	if CheckpointSystem.checkpoint == Vector2(330,-800):
		var rest_position = Vector2(230.0*4, -120.5*4)              # where the camera normally sits
		global_position = rest_position + Vector2(-100, -1200)   # start high up (tune this number)
		var t = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		t.tween_property(self, "global_position", rest_position, duration)
		await t.finished # the function waits here until the pan ends
		$"../player/player_controller".can_move = true 
	else:
		$"../player/player_controller".can_move = true 

func level_switch(target_position:Vector2):
	var t = create_tween().set_parallel().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(self, "global_position", target_position, 0.5)
	
func _ready() -> void:
	intro_pan(18.0)
