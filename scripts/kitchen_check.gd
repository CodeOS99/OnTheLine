extends Area3D

func _ready() -> void:
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		Globals.player.went_in_kitchen = true
