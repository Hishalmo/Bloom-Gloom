extends Area2D




func _on_body_entered(body: Node2D) -> void:
	$"../../level_camera".level_switch(Vector2(1269.0*4, -350.0*4))
	CheckpointSystem.checkpoint = global_position 
	var t = create_tween()
	t.tween_property($"../../tutorial3", "modulate:a", 0, 1)
	t.tween_property($"../../tutorial2", "modulate:a", 0, 1)
