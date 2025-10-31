extends StaticBody3D

var target_ang = 75*PI/180

func used():
	var tween = get_tree().create_tween()
	tween.tween_property($"..", "rotation", Vector3(0, target_ang, 0), 1.5)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_SINE)
	
	target_ang = 0 if target_ang != 0 else 75*PI/180
