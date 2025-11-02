class_name FlickeringCeilingLight extends Node3D

# Thank god for random youtube tutorials which provide the code for free :prayge:

# Export variables for easy tweaking in the editor
@export var lights_on: bool = true  # Toggle lights on/off
@export var flicker_intensity: float = 0.5  # How much the light flickers (0-1)
@export var flicker_speed: float = 15.0  # Speed of flicker changes
@export var random_intervals: bool = true  # Random flicker intervals
@export var complete_blackouts: bool = true  # Occasionally go completely dark
@export var blackout_chance: float = 0.02  # Chance per frame to blackout (0-1)
@export var blackout_duration: float = 0.15  # How long blackouts last in seconds

# Audio settings
@export_group("Audio")
@export var audio_player: AudioStreamPlayer3D  # Assign your audio player here
@export var base_volume: float = 10.0  # Normal volume level
@export var volume_flicker_intensity: float = 0.7  # How much volume varies with light

# Base values
var base_energy: float = 1.0
var base_range: float = 10.0

# Internal variables
var light: Light3D
var time_passed: float = 0.0
var is_blackout: bool = false
var blackout_timer: float = 0.0
var noise_offset: float = 0.0

func _ready():
	light = $OmniLight3D
	
	if light == null:
		push_error("SpookyLight: No Light3D child found!")
		return
	
	# Store base values
	base_energy = light.light_energy
	base_range = light.omni_range if light is OmniLight3D else light.spot_range
	
	# Setup audio player
	if audio_player != null:
		audio_player.autoplay = true
		audio_player.volume_db = base_volume
		if not audio_player.playing:
			audio_player.play()
	
	# Randomize starting offset for variety
	noise_offset = randf() * 1000.0

func _process(delta):
	if light == null:
		return
	
	# Check if lights are off
	if not lights_on:
		light.light_energy = 0.0
		if audio_player != null:
			audio_player.volume_db = -80.0
		return
	
	time_passed += delta
	
	# Handle blackouts
	if is_blackout:
		blackout_timer -= delta
		if blackout_timer <= 0:
			is_blackout = false
		else:
			light.light_energy = 0.0
			# Mute audio during blackout
			if audio_player != null:
				audio_player.volume_db = -80.0
			return
	
	# Random chance for complete blackout
	if complete_blackouts and randf() < blackout_chance:
		is_blackout = true
		blackout_timer = blackout_duration
		return
	
	# Calculate flicker using multiple noise frequencies for organic feel
	var flicker: float
	
	if random_intervals:
		# Use sine waves with different frequencies for organic flicker
		var fast = sin(time_passed * flicker_speed + noise_offset) * 0.5 + 0.5
		var medium = sin(time_passed * flicker_speed * 0.3 + noise_offset * 2) * 0.5 + 0.5
		var slow = sin(time_passed * flicker_speed * 0.1 + noise_offset * 3) * 0.5 + 0.5
		
		# Combine waves
		flicker = (fast * 0.5 + medium * 0.3 + slow * 0.2)
	else:
		# Simple sine wave flicker
		flicker = sin(time_passed * flicker_speed) * 0.5 + 0.5
	
	# Apply flicker intensity
	var energy_multiplier = 1.0 - (flicker_intensity * (1.0 - flicker))
	
	# Update light properties
	light.light_energy = base_energy * energy_multiplier
	
	# Also flicker the range slightly for extra effect
	var range_multiplier = 1.0 - (flicker_intensity * 0.3 * (1.0 - flicker))
	if light is OmniLight3D:
		light.omni_range = base_range * range_multiplier
	elif light is SpotLight3D:
		light.spot_range = base_range * range_multiplier
	
	# Update audio volume to match light intensity
	if audio_player != null:
		# Calculate volume based on light energy
		var volume_multiplier = 1.0 - (volume_flicker_intensity * (1.0 - energy_multiplier))
		audio_player.volume_db = base_volume * volume_multiplier
