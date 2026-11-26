extends Parallax2D



func _ready() -> void:
	visible = not Engine.is_editor_hint()
