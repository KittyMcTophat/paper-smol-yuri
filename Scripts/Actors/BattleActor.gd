extends "res://Scripts/Actors/Actor.gd"

signal attack_over

export var max_health : int = 10;
export var current_health : int = 10;
export(Array, PackedScene) var attacks : Array = [];

onready var _projectile_target_point : Spatial = $ProjectileTargetPoint;
onready var _jump_target_point : Spatial = $JumpTargetPoint;
onready var _healthbar : Spatial = $HealthBar;

func _ready():
	_healthbar._update_max_health(max_health);
	_healthbar._update_health(current_health);

func _do_an_attack() -> void:
	return;

func _hurt(damage : int = 1) -> void:
	#TODO: add particle showing damage amount
	current_health -= damage;
	current_health = _healthbar._update_health(current_health);
	
	if (current_health == 0):
		_kill();

func _kill() -> void:
	return;
