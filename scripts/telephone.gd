class_name Telephone extends StaticBody3D

var call_num: int = 0
var _is_ringing: bool = false
var _ring_tween: Tween

@onready var light := $Telephone/OmniLight3D
@onready var sound := $Telephone/TeleRing

func _ready() -> void:
	Globals.telephone = self

func ring():
	if _is_ringing:
		return
	_is_ringing = true
	call_num += 1
	sound.play()
	_start_wobble()
	light.visible = true

func stop_ring():
	if !_is_ringing:
		return
	_is_ringing = false
	if _ring_tween:
		_ring_tween.kill()
	transform.basis = Basis() # reset
	light.visible = false

func _start_wobble():
	_ring_tween = create_tween()
	_ring_tween.set_loops()
	
	var rot_angle = deg_to_rad(5)
	_ring_tween.tween_property($Telephone, "rotation_degrees", Vector3(0, 0, 5), 0.15).set_trans(Tween.TRANS_SINE)
	_ring_tween.tween_property($Telephone, "rotation_degrees", Vector3(0, 0, -5), 0.3).set_trans(Tween.TRANS_SINE)
	_ring_tween.tween_property($Telephone, "rotation_degrees", Vector3(0, 0, 0), 0.15).set_trans(Tween.TRANS_SINE)

func used():
	if not _is_ringing:
		return
	$Telephone/TeleRing.stop()
	Globals.player.make_black()
	await Globals.player.made_black
	await get_tree().create_timer(1).timeout
	$Telephone/Demand.play()

func _on_demand_finished() -> void:
	await get_tree().create_timer(1).timeout
	Globals.player.make_white()
	
	stop_ring()
