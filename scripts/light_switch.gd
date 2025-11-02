extends StaticBody3D
@onready var target_light: FlickeringCeilingLight = $"../FlickeringCeilingLight"

func used():
	target_light.lights_on = not target_light.lights_on
	$SwitchClick.play()
