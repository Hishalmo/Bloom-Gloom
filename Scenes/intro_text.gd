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

func outro_line() -> void:
	await show_line("And thus, the tale is told,", 5.0)
	await show_line("Each eye, a blindfold,", 4.0)
	await show_line("Each saw what the other couldn't know.", 7.0)
	await show_thank_you()


func show_thank_you() -> void:
	await show_line("Thank you for playing!", 5.0)
	await show_line("Feedbacks helps us improve our game <3", 5.0)
	label.text = "Press E to restart"
	label.modulate.a = 0.0
	var t = create_tween()
	t.tween_property(label, "modulate:a", 1.0, 1.5)
	await t.finished


#They were never whole,
#Bloom and Gloom,
#Two halves of a tale,
#Each blind to what the other could see. 

#And thus, the tale is told,
#Each eye, a blindfold,
#Each saw what the other couldn't know.


func play_ending() -> void:
	visible = true
	camera.ending_pan(18.0)
	await outro_line()


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
