extends Actor

class_name BattleActor

signal turn_over;

export var max_health : int = 10;
export var current_health : int = 10;
export var attack : int = 1;
export var jump_strength : float = 5.0;
export var gravity : Vector3 = Vector3(0.0, -9.8, 0.0);
export var dust_particles : PackedScene = null;
export(int, LAYERS_3D_PHYSICS) var target_collision_layers : int = 0;
export var target_direction : Vector3 = Vector3(-1.0, 0.0, 0.0);
export var default_projectile : PackedScene = null;

onready var _projectile_target_point : Position3D = $ProjectileTargetPoint;
onready var _projectile_spawn_point : Position3D = $ProjectileSpawnPoint;
onready var _healthbar : Spatial = $HealthBar;
onready var selector_arrow : Sprite3D = $SelectorArrow;

var velocity : Vector3 = Vector3.ZERO;
var was_on_floor_last_frame : bool = true;
var attack_boosts : int = 0;

func _ready():
	_healthbar._update_max_health(max_health);
	_healthbar._update_health(current_health, false);
	
	selector_arrow.visible = false;
	
	if (target_direction.x < 0.0):
		_sprite_3d.rotation_degrees.y = 180.0;

func _enter_tree():
	attack_boosts = 0;

func _physics_process(delta):
	velocity += gravity * delta;
	
	velocity = move_and_slide(velocity, Vector3.UP);
	
	if (is_on_floor() && !was_on_floor_last_frame):
		_squash(Vector3(1.1, 0.9, 1.1));
		_make_dust_particles();
	
	was_on_floor_last_frame = is_on_floor();

func _do_your_turn() -> void:
	_end_turn();

func _end_turn():
	emit_signal("turn_over");

func hurt(damage : int = 1, do_tween : bool = true) -> void:
	#TODO: add particle showing damage amount
	current_health -= damage;
	current_health = _healthbar._update_health(current_health, do_tween);
	
	if (current_health == 0):
		_kill();

func heal(amount : int = 1) -> void:
	#TODO: add particle showing heal amount
	current_health += amount;
	current_health = _healthbar._update_health(current_health, false);

func _kill() -> void:
	# https://www.youtube.com/watch?v=iVGVXPuO3xQ
	print("No health, gromit!");

func _fire_projectile(projectile : PackedScene = default_projectile, direction : Vector3 = target_direction, damage : int = attack, piereces_targets : bool = false):
	if (projectile == null):
		# https://www.youtube.com/watch?v=iVGVXPuO3xQ
		print("No projectile, gromit!");
		return;
	if (get_parent() == null):
		# https://www.youtube.com/watch?v=iVGVXPuO3xQ
		print("No parent, gromit!");
		return;
	
	var new_projectile = projectile.instance();
	
	get_parent().add_child(new_projectile);
	
	new_projectile.global_transform.origin = _projectile_spawn_point.global_transform.origin;
	
	new_projectile.set_direction(direction);
	new_projectile.damage = damage + attack_boosts;
	new_projectile.pierces_targets = piereces_targets;
	
	new_projectile.collision_mask = target_collision_layers;

func _jump(strength : float = jump_strength):
	velocity.y = strength;
	_squash(Vector3(0.9, 1.1, 0.9));
	_make_dust_particles();

func _make_dust_particles() -> void:
	if (dust_particles == null):
		return;
	var particle : Particles = dust_particles.instance();
	add_child(particle);

func _jump_and_fire_projectile(strength : float = jump_strength, projectile : PackedScene = default_projectile, direction : Vector3 = Vector3.LEFT, damage : int = attack, piereces_targets : bool = false):
	_jump(strength);
	
	# calculates the time until velocity is zero
	# this is the top of the jump, so that's when the projectile should be spawned
	var yield_time : float = abs(strength/gravity.y);
	yield(get_tree().create_timer(yield_time), "timeout");
	
	_fire_projectile(projectile, direction, damage, piereces_targets);
