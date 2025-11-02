extends StaticBody3D
@export var target_light: FlickeringCeilingLight

func used():
	target_light.lights_on = not target_light.lights_on
	$SwitchClick.play()
