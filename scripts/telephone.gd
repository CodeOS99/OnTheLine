class_name Telephone extends MeshInstance3D

var call_num: int = 0
var _is_ringing: bool = false
var _ring_tween: Tween

func _ready() -> void:
	Globals.telephone = self

func ring():
	if _is_ringing:
		return
	_is_ringing = true
	call_num += 1
	$TeleRing.play()
	_start_wobble()

func stop_ring():
	if !_is_ringing:
		return
	_is_ringing = false
	if _ring_tween:
		_ring_tween.kill()
	transform.basis = Basis() # reset

func _start_wobble():
	_ring_tween = create_tween()
	_ring_tween.set_loops()
	
	var rot_angle = deg_to_rad(5)
	_ring_tween.tween_property(self, "rotation_degrees", Vector3(0, 0, 5), 0.15).set_trans(Tween.TRANS_SINE)
	_ring_tween.tween_property(self, "rotation_degrees", Vector3(0, 0, -5), 0.3).set_trans(Tween.TRANS_SINE)
	_ring_tween.tween_property(self, "rotation_degrees", Vector3(0, 0, 0), 0.15).set_trans(Tween.TRANS_SINE)
