extends "res://Scripts/Actors/Actor.gd"

export var jump_strength : float = 5.0;
export var movement_speed : float = 4.0;
export var h_velocity_lerp_weight : float = 5.0;
export var midair_h_lerp_multiplier : float = 0.5;
export var midair_jumps : int = 0;
export var allow_moonjump : bool = false;
export var footstep_particle : PackedScene = null;

var _velocity : Vector3 = Vector3.ZERO;
var _grounded : bool = false;
var _midair_jumps_left : int = 0;

onready var _ground_detector_area : Area = $GroundDetector;

# gets the gravity from project settings
onready var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity");

func _physics_process(delta) -> void:
	_update_grounded();
	
	var move_direction := _get_movement_vector();
	
	# rotates the sprite to match movement
	if (move_direction.x > 0.1):
		_turn(0);
	elif (move_direction.x < -0.1):
		_turn(180);
	
	# changes the sprite to match movement
	if (move_direction.z < -0.1):
		_facing_back = true;
	elif (move_direction.z > 0.1):
		_facing_back = false;
	
	# applies the movement to velocity
	if (_grounded):
		_velocity.x = lerp(_velocity.x, move_direction.x * movement_speed, delta * h_velocity_lerp_weight);
		_velocity.z = lerp(_velocity.z, move_direction.z * movement_speed, delta * h_velocity_lerp_weight);
	else:
		if (abs(move_direction.x) > 0.1):
			_velocity.x = lerp(_velocity.x, move_direction.x * movement_speed, delta * h_velocity_lerp_weight * midair_h_lerp_multiplier);
		if (abs(move_direction.z) > 0.1):
			_velocity.z = lerp(_velocity.z, move_direction.z * movement_speed, delta * h_velocity_lerp_weight * midair_h_lerp_multiplier);
	
	# applies gravity to velocity
	_velocity.y -= _gravity * delta
	
	# jumping code
	if Global.allow_jump:
		if Input.is_action_just_pressed("jump"):
			if (_grounded || allow_moonjump):
				_velocity.y = jump_strength;
			elif(_midair_jumps_left > 0):
				_midair_jumps_left -= 1;
				_velocity.y = jump_strength;
		
	# applies the velocity to the kinematic body
	_velocity = move_and_slide(_velocity, Vector3.UP, true);
	
	_update_animation();

# updates the _grounded boolean
func _update_grounded() -> void:
	if (_ground_detector_area.get_overlapping_bodies().size() > 0):
		_grounded = true;
		_midair_jumps_left = midair_jumps;
	else:
		_grounded = false;

# creates a movement vector from user inputs
func _get_movement_vector() -> Vector3:
	var move_direction := Vector2.ZERO;
	
	move_direction = Input.get_vector("move_left","move_right","move_up","move_down");
	
	return Vector3(move_direction.x, 0, move_direction.y);

func _update_animation() -> void:
	if (_velocity.length() < 0.1):
		_play_anim("Idle");
		_anim_player.playback_speed = 1.0;
	else:
		_play_anim("Walking");
		_anim_player.playback_speed = _velocity.length();

func _make_footstep_particles() -> void:
	var particle : Particles = footstep_particle.instance();
	add_child(particle);
