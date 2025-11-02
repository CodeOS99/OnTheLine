extends CharacterBody3D

@export var player: Player
@export var orbital_radius: float = 1.5
@export var move_speed: float = 5.0
@export var noise_speed: float = 2.0
@export var vertical_limit: float = .6
@export var jitter_strength:float = .3
@export var can_move: bool = true

var target_pos: Vector3
var noise = FastNoiseLite.new()
var t: float = 0.0

func _ready():
	randomize()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	target_pos = global_position
	
func _process(delta: float) -> void:
	if not can_move:
		return
	
	if visible:
		if not $AudioStreamPlayer3D.playing:
			$AudioStreamPlayer3D.play()
	else:
		$AudioStreamPlayer3D.stop()
	
	if not player:
		print("No player?S?????")
		return
	
	t += delta*noise_speed
	
	var orbital_angle = t*.8
	var base_offset = Vector3(
		cos(orbital_angle),
		sin(t*.5) * vertical_limit,
		sin(orbital_angle)
	) * orbital_radius
	
	var noise_offset = Vector3(
		noise.get_noise_3d(t, 0, 0),
		noise.get_noise_3d(0, t, 0),
		noise.get_noise_3d(0, 0, t)
	) * jitter_strength
	
	target_pos = player.global_position + base_offset + noise_offset + Vector3(0, 1.6, 0)
	
	global_position = global_position.lerp(target_pos, delta*move_speed)
	
	look_at(player.global_position+Vector3(0, 1.6, 0), Vector3.UP)
