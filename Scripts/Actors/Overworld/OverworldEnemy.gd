extends Actor

class_name OverworldEnemy

signal battle_end
signal battle_start

export var move_speed : float = 2.0;
export var jump_strength : float = 5.0;
export var move_lerp : float = 5.0;
export var gravity : Vector3 = Vector3(0.0, -9.8, 0.0);
export(Array, PackedScene) var enemies : Array = [];
export var dust_particles : PackedScene = null;
export var reward_money : int = 25;

var enemies_instanced : Array = []

var target : Spatial = null;
var velocity : Vector3 = Vector3.ZERO;
var was_on_floor_last_frame : bool = true;

onready var ground_raycast : RayCast = $GroundRayCast;

# Called when the node enters the scene tree for the first time.
func _ready():
	for enemy in enemies:
		enemies_instanced.push_back(enemy.instance());

func _physics_process(delta):
	velocity += gravity * delta;
	
	if (target != null):
		var vector_to_target : Vector3 = target.global_transform.origin - global_transform.origin;
		vector_to_target.y = 0.0;
		
		vector_to_target = vector_to_target.normalized();
		vector_to_target *= move_speed;
		
		velocity.x = lerp(velocity.x, vector_to_target.x, delta * move_lerp);
		velocity.z = lerp(velocity.z, vector_to_target.z, delta * move_lerp);
		
		if (vector_to_target.x > 0.1):
			_turn(0);
		elif (vector_to_target.x < -0.1):
			_turn(180);
		
		if (vector_to_target.z < -0.1):
			_facing_back = true;
		elif (vector_to_target.z > 0.1):
			_facing_back = false;
	
	velocity = move_and_slide(velocity, Vector3.UP);
	
	if (is_on_floor() && !was_on_floor_last_frame):
		_squash(Vector3(1.1, 0.9, 1.1));
		_make_dust_particles();
	
	if (is_on_wall() && is_on_floor()):
		_jump();
	else:
		if (is_on_floor()):
			ground_raycast.force_raycast_update()
			if (!ground_raycast.is_colliding()):
				_jump();
	
	was_on_floor_last_frame = is_on_floor();

func _jump():
	velocity.y = jump_strength;
	_squash(Vector3(0.9, 1.1, 0.9));
	_make_dust_particles();

func _make_dust_particles() -> void:
	if (dust_particles == null):
		return;
	var particle : Particles = dust_particles.instance();
	add_child(particle);

func _on_AggroArea_body_entered(body):
	if (body is Player):
		target = body;

func _on_PlayerDetectorArea_body_entered(body):
	if (body is Player && !Global.current_level_controller.battle._battle_is_active):
		Global.current_level_controller.battle.start_battle(body.party, enemies_instanced);
	# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("battle_start", self, "_battle_start");
	# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("battle_end", self, "_battle_end");

func _battle_start():
	emit_signal("battle_start");

func _battle_end():
	emit_signal("battle_end");
	Global.coin_counter.add_money(reward_money);
	_kill();

func _kill():
	queue_free();

func _notification(what : int):
	if (what == NOTIFICATION_PREDELETE):
		for enemy in enemies_instanced:
			if (is_instance_valid(enemy)):
				enemy.queue_free();
