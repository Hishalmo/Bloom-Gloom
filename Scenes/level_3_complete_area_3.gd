extends Area2D


func _on_body_entered(body: Node2D) -> void:
	$"../../level_camera".level_switch(Vector2(7614.0, -1509.0))
	CheckpointSystem.checkpoint = global_position 
