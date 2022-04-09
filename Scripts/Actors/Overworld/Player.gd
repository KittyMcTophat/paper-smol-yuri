extends Actor

class_name Player

export(Resource) var movement_params = null;

export var dust_particles : PackedScene = null;

# Health variables
export var hazard_damage : int = 1;
export var max_health : int = 10;
export var cur_health : int = 10;
export var reload_on_death : bool = true;
export(Array, PackedScene) var party_scenes : Array = [];

var _velocity : Vector3 = Vector3.ZERO;
var _last_safe_location : Vector3 = Vector3.ZERO;
var _grounded : bool = false;
var _midair_jumps_left : int = 0;
var _was_on_floor_last_frame : bool = true;

var party : Array = [];

onready var _ground_detector_area : Area = $GroundDetector;
onready var _harm_detector_area : Area = $HarmDetector;
onready var _safe_ground_raycast : RayCast = $SafeGroundRaycast;
onready var _healthbar : Spatial = $HealthBar;

func _ready():
	_healthbar._update_max_health(max_health);
	_healthbar._update_health(cur_health);
	
	_last_safe_location = transform.origin;

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
		_velocity.x = lerp(_velocity.x, move_direction.x * movement_params.movement_speed,\
		delta * movement_params.h_velocity_lerp_weight);
		
		_velocity.z = lerp(_velocity.z, move_direction.z * movement_params.movement_speed,\
		delta * movement_params.h_velocity_lerp_weight);
	else:
		if (abs(move_direction.x) > 0.1):
			_velocity.x = lerp(_velocity.x, move_direction.x * movement_params.movement_speed,\
			delta * movement_params.h_velocity_lerp_weight * movement_params.midair_h_lerp_multiplier);
		if (abs(move_direction.z) > 0.1):
			_velocity.z = lerp(_velocity.z, move_direction.z * movement_params.movement_speed,\
			delta * movement_params.h_velocity_lerp_weight * movement_params.midair_h_lerp_multiplier);
	
	# applies gravity to velocity
	_velocity += movement_params.gravity * delta;
	
	# jumping code
	if Global.allow_jump:
		if Input.is_action_just_pressed("jump"):
			if (_grounded || movement_params.allow_moonjump):
				_jump();
			elif(_midair_jumps_left > 0):
				_midair_jumps_left -= 1;
				_jump();
	
	if (!Input.is_action_pressed("jump") && !is_on_floor()):
		if (_velocity.y > 0):
			_velocity.y = lerp(_velocity.y, 0, movement_params.vertical_lerp_weight * delta);
	
	# applies the velocity to the kinematic body
	_velocity = move_and_slide(_velocity, Vector3.UP, true);
	
	if (is_on_floor() && !_was_on_floor_last_frame):
		_squash(Vector3(1.1, 0.9, 1.1));
		_make_dust_particles();
	
	_was_on_floor_last_frame = is_on_floor();
	
	if (transform.origin.y < movement_params.kill_y):
		_go_to_last_safe_spot();
	
	# if it collided with a harmful object, returns to the last safe spot
	for i in get_slide_count():
		if (get_slide_collision(i).collider.get_collision_layer_bit(2)):
			_go_to_last_safe_spot();
			break;
	
	_update_animation();
	_update_last_safe_spot();

func _jump() -> void:
	_velocity.y = movement_params.jump_strength;
	_squash(Vector3(0.9, 1.1, 0.9));
	_make_dust_particles();

# updates the _grounded boolean
func _update_grounded() -> void:
	if (_ground_detector_area.get_overlapping_bodies().size() > 0):
		_grounded = true;
		_midair_jumps_left = movement_params.midair_jumps;
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
	elif (is_on_floor()):
		_play_anim("Walking");
		_anim_player.playback_speed = _velocity.length();
	else:
		_play_anim("Jumping");
		_anim_player.playback_speed = 1.0;

func _make_dust_particles() -> void:
	if (dust_particles == null):
		return;
	var particle : Particles = dust_particles.instance();
	add_child(particle);

func _update_last_safe_spot():
	_safe_ground_raycast.force_raycast_update();
	
	if (_safe_ground_raycast.is_colliding() && !(_harm_detector_area.get_overlapping_bodies().size() > 0)):
		_last_safe_location = transform.origin;

func _go_to_last_safe_spot():
	hurt(hazard_damage);
	
	transform.origin = _last_safe_location;
	_velocity = Vector3.ZERO;

func hurt(damage : int = 1):
	#TODO: add particle with damage number
	cur_health -= damage;
	cur_health = _healthbar._update_health(cur_health);
	
	if (cur_health == 0):
		_kill();

func _kill():
	if (reload_on_death):
		Global.reload_scene();
