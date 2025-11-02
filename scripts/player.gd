class_name Player extends CharacterBody3D

var speed
const WALK_SPEED = 3.0
const SENSITIVITY = 0.004

#bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0

#fov variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

var gravity = 9.8*2

@onready var head = $Head
@onready var camera = $Head/Camera3D

var swatted_fly := false
var fly_two := false # can swat fly for the second time
var done_with_fly := false

var went_in_room_one := false
var went_in_bathroom := false
var went_in_kitchen := false
var went_in_balcony := false

var got_call_once := false

signal made_black

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Globals.player = self
	$Fly.visible = true

func _unhandled_input(event):
	if ($AnimationPlayer.is_playing() and $AnimationPlayer.current_animation in ["wake_up", "fly_sacrifice"]) or ($Control/Blocker2/Blocker.modulate.a >= 240):
		return
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta):
	if ($AnimationPlayer.is_playing() and $AnimationPlayer.current_animation in ["wake_up", "fly_sacrifice"]) or ($Control/Blocker2/Blocker.modulate.a >= 240):
		return
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	speed = WALK_SPEED
		
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		if not $footsteps.playing:
			$footsteps.play()
		$footsteps.set_stream_paused(false)
	else:
		$footsteps.set_stream_paused(true)
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	
	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, WALK_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	move_and_slide()

func _process(delta: float) -> void:
	$Control/NonBlocker/SwatLabel.visible = (not swatted_fly) or fly_two
	
	update_objective()
	
	if Input.is_action_just_pressed("swat") and ((not swatted_fly) or (swatted_fly and fly_two)) and not $Control/NonBlocker/FlySacrificeLabel.visible:
		$AnimationPlayer.play("swat")
		$Control/NonBlocker/SwatLabel.visible = false
		$Fly.visible = false
		if not fly_two:
			$Control/NonBlocker/ObjectiveLabel.text = "Reorient yourself(explore)"
		else:
			$Control/NonBlocker/ObjectiveLabel.text = "Continue exploration"
			fly_two = false
		swatted_fly = true
	elif Input.is_action_just_pressed("swat") and $Control/NonBlocker/FlySacrificeLabel.visible:
		$Fly.can_move = false
		$AnimationPlayer.play("fly_sacrifice")

func update_objective():
	if went_in_balcony and went_in_bathroom and went_in_kitchen and went_in_room_one and not got_call_once:
		$Control/NonBlocker/ObjectiveLabel.text = "Check phone"
		got_call_once = true
		Globals.telephone.ring()
	
	if int(went_in_balcony) + int(went_in_bathroom) + int(went_in_kitchen) + int(went_in_room_one) == 2 and not done_with_fly:
		$Control/NonBlocker/ObjectiveLabel.text = "Swat the fly again"
		fly_two = true
		$Fly.visible = true
		$Fly.can_move = true
		done_with_fly = true

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func make_black():
	$AnimationPlayer.play("make_black")

func make_white():
	$AnimationPlayer.play("make_white")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "make_black":
		made_black.emit()
	if anim_name == "fly_sacrifice":
		make_black()

func initiate_fly_killing():
	$Control/NonBlocker/ObjectiveLabel.text = "S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce S∆cr!f!ce"
	$Control/NonBlocker/FlySacrificeLabel.visible = true
	$Fly.visible = true
	$Fly.can_move = true

func get_scared():
	$Heartbeat.play()
	$BreathingScary.play()
	$Head/Camera3D.should_shake = true
	$NormalBreath.stop()

func _on_breathing_scary_finished() -> void:
	$NormalBreath.play()
