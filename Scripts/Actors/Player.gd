extends "res://Scripts/Actors/Actor.gd"

export var jump_strength : float = 5.0;
export var movement_speed : float = 4.0;
export var h_velocity_lerp_weight : float = 5.0;
export var midair_h_lerp_multiplier : float = 0.5;

export var midair_jumps : int = 0;

export var allow_moonjump : bool = false;

var _velocity := Vector3.ZERO;
var _grounded := false;
var _facing_back := false;
var _midair_jumps_left : int = 0;

onready var _spring_arm: SpringArm = $SpringArm;
onready var _anim_player: AnimationPlayer = get_node("AnimationPlayer");
onready var _ground_detector_area: Area = $GroundDetector;

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
	_play_anim("Walking");
	
	# applies the movement to velocity
	if (_grounded):
		_velocity.x = lerp(_velocity.x, move_direction.x * movement_speed, delta * h_velocity_lerp_weight);
		_velocity.z = lerp(_velocity.z, move_direction.z * movement_speed, delta * h_velocity_lerp_weight);
	else:
		if (abs(move_direction.x) > 0.1):
			_velocity.x = lerp(_velocity.x, move_direction.x * movement_speed, delta * h_velocity_lerp_weight * midair_h_lerp_multiplier);
		if (abs(move_direction.z) > 0.1):
			_velocity.z = lerp(_velocity.z, move_direction.z * movement_speed, delta * h_velocity_lerp_weight * midair_h_lerp_multiplier);
	
	if (_velocity.length() < 0.1):
		_play_anim("Idle");
	
	# applies gravity to velocity
	_velocity.y -= _gravity * delta
	
	# allows jumping
	if Input.is_action_just_pressed("jump"):
		if (_grounded || allow_moonjump):
			_velocity.y = jump_strength;
		elif(_midair_jumps_left > 0):
			_midair_jumps_left -= 1;
			_velocity.y = jump_strength;
	
	# applies the velocity to the kinematic body
	_velocity = move_and_slide(_velocity, Vector3.UP, true);

# resets the animation when a non-looping animation finishes
func _on_AnimationPlayer_animation_finished(_anim_name) -> void:
	_play_anim("Idle");

# plays an animation, and uses the back version if needed
func _play_anim(anim_name : String) -> void:
	if (_anim_player == null):
		return;
	if (_facing_back):
		anim_name = anim_name + "_Back";
	if (_anim_player.current_animation == anim_name):
		return;
	_anim_player.play(anim_name);

# updates the _grounded boolean
func _update_grounded() -> void:
	if (_ground_detector_area.get_overlapping_bodies().size() > 0):
		_grounded = true;
		_midair_jumps_left = midair_jumps;
	else:
		_grounded = false;

# creates a movement vector from user inputs
func _get_movement_vector() -> Vector3:
	var move_direction := Vector3.ZERO;
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	move_direction.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up");
	
	# normalizes the movement vector if it is greater than 1
	if (move_direction.length() > 1):
		move_direction = move_direction.normalized();
	
	return move_direction;
