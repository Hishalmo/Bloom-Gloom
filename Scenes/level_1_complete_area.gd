extends Area2D




func _on_body_entered(body: Node2D) -> void:
	$"../../level_camera".level_switch(Vector2(862.0, -117))
