extends Area2D



func _physics_process(delta: float) -> void:
	if $"..".is_grey == true and has_overlapping_bodies():
		$"..".restart()
