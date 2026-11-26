extends Node2D


@export var music: AudioStreamPlayer 

func Ost_change(is_grey: bool) -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	var reverb = AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectReverb
	var lowpass = AudioServer.get_bus_effect(bus_idx, 1) as AudioEffectLowPassFilter

	var tween = create_tween().set_parallel(true)
	tween.tween_property(AudioServer, "playback_speed_scale", 0.85 if is_grey else 1.0, 1.0)
	tween.tween_property(reverb, "wet", 0.6 if is_grey else 0.0, 2.0)
	tween.tween_property(lowpass, "cutoff_hz", 900.0 if is_grey else 20500.0, 1.0)
