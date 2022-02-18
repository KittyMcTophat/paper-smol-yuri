extends KinematicBody

export var jump_strength : float = 5.0;
export var movement_speed : float = 5.0;
export var midair_speed_mult : float = 0.75;
export var full_turn_time : float = 0.5;
export var allow_moonjump : bool = false;

var _velocity := Vector3.ZERO;
var _facing_right := true;
var _grounded := false;
var _facing_back := false;

onready var _spring_arm: SpringArm = $SpringArm;
onready var _anim_player: AnimationPlayer = $AnimationPlayer;
onready var _sprite_3d: Sprite3D = $Sprite3D;
onready var _tween_node: Tween = $Tween;
onready var _ground_detector_area: Area = $GroundDetector;

# gets the gravity from project settings
onready var _gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity");

func _physics_process(delta) -> void:
	_update_grounded();
	
	var move_direction := _get_move_direction();
	
	# rotates the sprite to match movement
	if (move_direction.x > 0.1):
		_turn(0);
	elif (move_direction.x < -0.1):
		_turn(180);
	
	# changes the sprite to match movement
	if (move_direction.z < -0.1):
		_anim_player.play("Idle_Back");
		_facing_back = true;
	elif (move_direction.z > 0.1):
		_anim_player.play("Idle");
		_facing_back = false;
	
	# applies the midair speeed multiplier if not grounded
	if (!_grounded):
		move_direction *= midair_speed_mult;
	
	# applies the movement to velocity
	_velocity.x = move_direction.x * movement_speed;
	_velocity.z = move_direction.z * movement_speed;
	
	# applies gravity to velocity
	_velocity.y -= _gravity * delta
	
	# allows jumping and snapping
	if (_grounded || allow_moonjump) && Input.is_action_just_pressed("jump"):
		_velocity.y = jump_strength;
	
	# applies the velocity to the kinematic body
	_velocity = move_and_slide(_velocity, Vector3.UP, true);

# resets the animation when a non-looping animation finishes
func _on_AnimationPlayer_animation_finished(_anim_name) -> void:
	_anim_player.play("Idle");

# uses the Tween node to rotate the sprite smoothly
func _turn(target_rotation: float, dead_zone: float = 5.0) -> void:
	var current_rotation: Vector3 = _sprite_3d.transform.basis.get_euler();
	var distance_to_rotate: float = abs(target_rotation - rad2deg(current_rotation.y));
	
	# cancels the rotation if it is within the dead zone
	if (distance_to_rotate < dead_zone || abs(distance_to_rotate - 360) < dead_zone):
		return;
	
	# if it would be quicker, rotates the other way
	if (distance_to_rotate > 180):
		target_rotation -= 360;
		distance_to_rotate = abs(target_rotation - rad2deg(current_rotation.y));
	
	# calculates the duration of the tween to maintain consistent rotational velocity
	var duration: float = full_turn_time * (distance_to_rotate / 360);
	
	# applies the tween
	var target_rotation_vector: Vector3 = Vector3(current_rotation.x, target_rotation, current_rotation.z);
# warning-ignore:return_value_discarded
	_tween_node.interpolate_property(_sprite_3d, "rotation_degrees",\
	null, target_rotation_vector, duration, Tween.TRANS_LINEAR);
# warning-ignore:return_value_discarded
	_tween_node.start();

# updates the _grounded boolean
func _update_grounded() -> void:
	if (_ground_detector_area.get_overlapping_bodies().size() > 0):
		_grounded = true;
	else:
		_grounded = false;

# creates a movement vector from user inputs
func _get_move_direction() -> Vector3:
	var move_direction := Vector3.ZERO;
	move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left");
	move_direction.z = Input.get_action_strength("move_down") - Input.get_action_strength("move_up");
	move_direction = move_direction.rotated(Vector3.UP, _spring_arm.rotation.y);
	
	# normalizes the movement vector if it is greater than 1
	if (move_direction.length() > 1):
		move_direction = move_direction.normalized();
	
	return move_direction;
