extends Area2D

@export var ending_text: CanvasLayer

var triggered := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if triggered:
		return

	if body.name == "player":
		triggered = true
		await ending_text.play_ending()
