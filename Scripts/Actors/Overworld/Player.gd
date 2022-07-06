extends Actor

class_name Player

signal landed;

export(Resource) var movement_params = null;

export var dust_particles : PackedScene = null;

# Health variables
export var hazard_damage : int = 1;
export var max_health : int = 10;
export var cur_health : int = 10;
export var reload_on_death : bool = true;
export(Array, PackedScene) var party_scenes : Array = [];
export var party_leader : int = 0;
export var v_camera_speed : float = PI / 4.0;
export var h_camera_speed : float = PI / 2.0;
export var max_camera_angle : float = PI / 6.0;
export var min_camera_angle : float = -PI / 4.0;

var _velocity : Vector3 = Vector3.ZERO;
var _last_safe_location : Vector3 = Vector3.ZERO;
var _was_on_floor_last_frame : bool = true;
var allow_movement : bool = true;
var _jump_buffer : float = 0.0;
var _coyote_time : float = 0.0;

var party : Array = [];

onready var _harm_detector_area : Area = $HarmDetector;
onready var _safe_ground_raycast : RayCast = $SafeGroundRaycast;
onready var _healthbar : HealthBar2D = $HealthBar
onready var camera_springarm : SpringArm = $SpringArm;

func _ready():
	_healthbar._update_max_health(max_health);
# warning-ignore:return_value_discarded
	_healthbar._update_health(cur_health, false);
	
	_last_safe_location = transform.origin;
	
	for i in range(party_scenes.size()):
		party.push_back(party_scenes[i].instance());
		add_child(party[i]);
		remove_child(party[i]);
		party[i].personal_jump_input = "jump_" + str(i + 1);
	
	yield(get_tree(), "idle_frame");
# warning-ignore:return_value_discarded
	Global.current_level_controller.battle.connect("battle_end_early", self, "_after_battle");
	
# warning-ignore:return_value_discarded
	self.connect("landed", self, "_check_jump_buffer");
	
	Global.set_camera_rotation(camera_springarm.rotation.y);

func _physics_process(delta) -> void:
	if (allow_movement == false):
		return;
	
	var move_direction := _get_movement_vector();
	
	var h_input : float = Input.get_axis("move_left", "move_right");
	var v_input : float = Input.get_axis("move_up", "move_down");
	
	# rotates the sprite to match movement
	if (h_input > 0.1):
		_turn(0);
	elif (h_input < -0.1):
		_turn(180);
	
	# changes the sprite to match movement
	if (v_input < -0.1):
		_facing_back = true;
	elif (v_input > 0.1):
		_facing_back = false;
	
	# applies the movement to velocity
	if (is_on_floor()):
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
			if (movement_params.allow_moonjump):
				_jump();
			elif (_coyote_time > 0.0):
				_jump();
				_coyote_time = 0.0;
			elif (is_on_floor()):
				_jump();
			else:
				_jump_buffer = movement_params.jump_buffer_time;
	
	if (!Input.is_action_pressed("jump") && !is_on_floor()):
		if (_velocity.y > 0):
			_velocity.y = lerp(_velocity.y, 0, movement_params.vertical_lerp_weight * delta);
	
	# applies the velocity to the kinematic body
	_velocity = move_and_slide(_velocity, Vector3.UP, true);
	
	if (is_on_floor() && !_was_on_floor_last_frame):
		_squash(Vector3(1.1, 0.9, 1.1));
		_make_dust_particles();
		emit_signal("landed");
	
	if (!is_on_floor() && _was_on_floor_last_frame && _velocity.y < 0.0):
		_coyote_time = movement_params.coyote_time;
	
	_was_on_floor_last_frame = is_on_floor();
	
	if (_coyote_time > 0.0):
		_coyote_time -= delta;
	
	if (_jump_buffer > 0.0):
		_jump_buffer -= delta;
	
	if (transform.origin.y < movement_params.kill_y):
		_go_to_last_safe_spot();
	
	# if it collided with a harmful object, returns to the last safe spot
	for i in get_slide_count():
		if (get_slide_collision(i).collider.get_collision_layer_bit(2)):
			_go_to_last_safe_spot();
			break;
	
	_update_animation();
	_update_last_safe_spot();
	
	var h_camera_input : float = Input.get_axis("camera_left", "camera_right");
	var v_camera_input : float = Input.get_axis("camera_up", "camera_down");
	
	if h_camera_input != 0.0:
		camera_springarm.rotation.y += h_camera_speed * Input.get_axis("camera_left", "camera_right") * delta;
		Global.set_camera_rotation(camera_springarm.rotation.y);
	
	if v_camera_input != 0.0:
		camera_springarm.rotation.x += v_camera_speed * Input.get_axis("camera_up", "camera_down") * delta;
		if camera_springarm.rotation.x > max_camera_angle:
			camera_springarm.rotation.x = max_camera_angle;
		elif camera_springarm.rotation.x < min_camera_angle:
			camera_springarm.rotation.x = min_camera_angle;

func _check_jump_buffer():
	if (is_on_floor() && _jump_buffer > 0.0):
		_jump();
		_jump_buffer = 0.0;

func _jump() -> void:
	_velocity.y = movement_params.jump_strength;
	_squash(Vector3(0.9, 1.1, 0.9));
	_make_dust_particles();
	$Jump.play();

# creates a movement vector from user inputs
func _get_movement_vector() -> Vector3:
	var move_direction := Vector2.ZERO;
	
	move_direction = Input.get_vector("move_left","move_right","move_up","move_down");
	
	move_direction = move_direction.rotated(-camera_springarm.rotation.y);
	
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
	
	if (_safe_ground_raycast.is_colliding() && !(_harm_detector_area.get_overlapping_bodies().size() > 0) && is_on_floor()):
		_last_safe_location = transform.origin;

func _go_to_last_safe_spot():
	hurt(hazard_damage);
	
	if (cur_health > 0):
		transform.origin = _last_safe_location;
		_velocity = Vector3.ZERO;
		_was_on_floor_last_frame = true;
		_squash(Vector3(1.0, 1.0, 1.0));

func hurt(damage : int = 1):
	cur_health -= damage;
	cur_health = _healthbar._update_health(cur_health);
	party[party_leader].hurt(damage, false);
	
	if (cur_health == 0):
		_kill();
	else:
		if is_inside_tree():
			$Hurt.play();

func _after_battle():
	yield(get_tree(), "idle_frame");
	
	cur_health = party[party_leader].current_health;
# warning-ignore:return_value_discarded
	_healthbar._update_health(cur_health, false);
# warning-ignore:return_value_discarded
	_tween_node.start();

func _kill():
	if (is_inside_tree() == false):
		return;
	
	_healthbar.hide();
	allow_movement = false;
	
	MusicManager.change_music(null);
	$Death.play();
	
	self.remove_child(camera_springarm);
	
# warning-ignore:return_value_discarded
	get_fuckin_launched();
	
	self.add_child(camera_springarm);
	
	yield(get_tree().create_timer(3.0, false), "timeout");
	
	if (reload_on_death):
		Global.reload_scene();
	else:
		queue_free();

func _notification(what : int):
	if (what == NOTIFICATION_PREDELETE):
		for i in party:
			if (is_instance_valid(i)):
				i.queue_free();
