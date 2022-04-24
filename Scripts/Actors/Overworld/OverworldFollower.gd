extends Actor

export var move_speed : float = 4.0;
export var jump_strength : float = 5.0;
export var move_lerp : float = 5.0;
export var gravity : Vector3 = Vector3(0.0, -9.8, 0.0);
export var dust_particles : PackedScene = null;
export var follow_distance : float = 0.75;
export var teleport_distance : float = 6.0;

onready var follow_target : Spatial = null;

var was_on_floor_last_frame : bool = true;
var velocity : Vector3 = Vector3.ZERO;

func _ready():
	follow_target = get_parent();
	var position = global_transform.origin;
	
	yield(get_tree(), "idle_frame");
	var new_parent : Spatial = Global.current_level_controller.overworld;
	follow_target.remove_child(self);
	new_parent.add_child(self);
	global_transform.origin = position;

func _physics_process(delta):
	velocity += gravity * delta;
	
	var vector_to_target : Vector3 = follow_target.global_transform.origin - global_transform.origin;
	
	if (vector_to_target.length() < follow_distance):
		vector_to_target = Vector3.ZERO;
	
	if (vector_to_target.length() > teleport_distance):
		_teleport_to_target();
		vector_to_target = Vector3.ZERO;
	
	if (vector_to_target.y > 0.5 && is_on_floor()):
		_jump();
	
	vector_to_target.y = 0.0;
	vector_to_target = vector_to_target.normalized();
	
	if (vector_to_target.x > 0.3):
		_turn(0);
	elif (vector_to_target.x < -0.3):
		_turn(180);
	
	if (vector_to_target.z < -0.3):
		_facing_back = true;
	elif (vector_to_target.z > 0.3):
		_facing_back = false;
	
	vector_to_target *= move_speed;
	
	velocity.x = lerp(velocity.x, vector_to_target.x, delta * move_lerp);
	velocity.z = lerp(velocity.z, vector_to_target.z, delta * move_lerp);
	
	velocity = move_and_slide(velocity, Vector3.UP, true);
	
	# if it collided with a harmful object, returns to the last safe spot
	for i in get_slide_count():
		if (get_slide_collision(i).collider.get_collision_layer_bit(2)): # HARMFUL
			_teleport_to_target();
			break;
	
	if (is_on_floor() && !was_on_floor_last_frame):
		_squash(Vector3(1.1, 0.9, 1.1));
		_make_dust_particles();
	
	if (is_on_wall() && is_on_floor()):
		_jump();
	
	was_on_floor_last_frame = is_on_floor();
	
	_update_animation();

func _teleport_to_target():
	global_transform.origin = follow_target.global_transform.origin;
	velocity = Vector3.ZERO;

func _update_animation():
	if (velocity.length() < 0.1):
		_play_anim("Idle");
		_anim_player.playback_speed = 1.0;
	elif (is_on_floor()):
		_play_anim("Walking");
		_anim_player.playback_speed = velocity.length();
	else:
		_play_anim("Jumping");
		_anim_player.playback_speed = 1.0;

func _jump():
	velocity.y = jump_strength;
	_squash(Vector3(0.9, 1.1, 0.9));
	_make_dust_particles();

func _make_dust_particles() -> void:
	if (dust_particles == null):
		return;
	var particle : Particles = dust_particles.instance();
	add_child(particle);
