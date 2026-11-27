extends Node2D

@onready var death: ColorRect = $death/death
@export var music: AudioStreamPlayer 
var player_controller: CharacterBody2D 

func Ost_change(is_grey: bool) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	var reverb = AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectReverb
	var lowpass = AudioServer.get_bus_effect(bus_idx, 1) as AudioEffectLowPassFilter

	var tween = create_tween().set_parallel(true)
	tween.tween_property(AudioServer, "playback_speed_scale", 0.85 if is_grey else 1.0, 1.0)
	tween.tween_property(reverb, "wet", 0.6 if is_grey else 0.0, 2.0)
	tween.tween_property(lowpass, "cutoff_hz", 900.0 if is_grey else 20500.0, 1.0)



# death animation
func _death():
		$death_fade.play()
		var shader = death.material as ShaderMaterial
		var t = create_tween()
		t.tween_property(shader, "shader_parameter/height", 0.5, 0.4)

func spawn():
		var shader = death.material as ShaderMaterial
		var t = create_tween()
		t.tween_property(shader, "shader_parameter/height", -1, 0.4)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("E") and CheckpointSystem.finished_the_game == true:
		player_controller.restart()
