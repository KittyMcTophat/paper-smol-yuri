extends Actor

class_name BattleActor

signal turn_over;

export var max_health : int = 10;
export var current_health : int = 10;
export var attack : int = 1;
export var target_collision_layer : int = 2;
export var projectile : PackedScene = null;

onready var _projectile_target_point : Spatial = $ProjectileTargetPoint;
onready var _projectile_spawn_point : Spatial = $ProjectileSpawnPoint;
onready var _healthbar : Spatial = $HealthBar;

func _ready():
	_healthbar._update_max_health(max_health);
	_healthbar._update_health(current_health);

func _do_your_turn() -> void:
	emit_signal("turn_over");
	return;

func hurt(damage : int = 1) -> void:
	#TODO: add particle showing damage amount
	current_health -= damage;
	current_health = _healthbar._update_health(current_health);
	
	if (current_health == 0):
		_kill();

func _kill() -> void:
	print("No health, gromit!");

func _fire_projectile(direction : Vector3 = Vector3.LEFT, damage : int = attack):
	if (projectile == null):
		return;
	
	var new_projectile = projectile.instance();
	
	add_child(new_projectile);
	new_projectile.transform.origin = _projectile_spawn_point.transform.origin;
	
	new_projectile.direction = direction;
	new_projectile.damage = damage;
	
	if (!new_projectile.get_collision_mask_bit(target_collision_layer)):
		new_projectile.collision_mask += pow(2, target_collision_layer - 1);
