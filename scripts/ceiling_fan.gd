extends Node3D

@export var observing_light: FlickeringCeilingLight

var on := false
var rem_t := 1.3 # time before scare
var finished = false

func _process(delta: float) -> void:
	if observing_light.lights_on and not on:
		on = true
		$FanWhoosh.play()
		$AnimationPlayer.play('fan_whirl')
	
	if on and rem_t > 0 and not finished:
		rem_t -= delta
	
	if rem_t <= 0 and not finished:
		print('played')
		finished = true
		$GlassBreakOne.play()
		$GlassBreakTwo.play()
		$GlassBreakThree.play()
		Globals.player.get_scared()
		$breaking_particles.emitting = true
