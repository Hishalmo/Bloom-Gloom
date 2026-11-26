extends CanvasLayer

@export var player : CharacterBody2D
@export var camera : Camera2D
@onready var label: Label = $Label
var line_number :=0

func show_line(line: String, hold: float) -> void:
	label.text = line
	var t = create_tween()
	t.tween_property(label, "modulate:a", 1.0, 0.8)   # fade in
	t.tween_interval(hold)                            # stay visible
	t.tween_property(label, "modulate:a", 0.0, 0.8)   # fade out
	await t.finished




func _ready() -> void:
	if CheckpointSystem.checkpoint == Vector2(330,-800):
		await show_line("This is a tale of two,", 2.0)
		line_number += 1
		await show_line("A tale of Bloom,", 2.0)
		line_number += 1
		await show_line("And a tale of Gloom", 2.0)
		visible = false

func _physics_process(delta: float) -> void:
	if line_number == 1:
		label.modulate = Color("b9a29f")
	if line_number == 2:
		label.modulate = Color("2d33ca")
