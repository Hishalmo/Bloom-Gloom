extends Area2D




func _on_body_entered(body: Node2D) -> void:
	$"../../level_camera".level_switch(Vector2(282.0*4, -120.5*4))
	CheckpointSystem.checkpoint = global_position 
