extends ShapeCast3D

var can_interact := false

func _physics_process(delta):
	if not $"../../..".swatted_fly:
		return
	self.force_shapecast_update()
	
	can_interact = false
	if self.is_colliding():
		if self.get_collider(0).is_in_group("interactable"):
			can_interact = true
	$"../../../Control/NonBlocker/InteractLabel".visible = can_interact
	
	if can_interact and Input.is_action_just_pressed("interact"):
		self.get_collider(0).used()
