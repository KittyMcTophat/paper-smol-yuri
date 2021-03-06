extends Actor

class_name OverworldEnemy

signal battle_start
signal battle_start_early
signal battle_end
signal battle_end_early
signal turn_ended(turn_number)

export var move_speed : float = 2.0;
export var jump_strength : float = 5.0;
export var move_lerp : float = 5.0;
export var gravity : Vector3 = Vector3(0.0, -9.8, 0.0);
export(Array, PackedScene) var enemies : Array = [];
export var dust_particles : PackedScene = null;
export var reward_money : int = 25;
export var override_music : bool = false;
export var music : AudioStream = null;

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
		
		var local_movement : Vector2 = Vector2(vector_to_target.x, vector_to_target.z).rotated(Global.camera_rotation);
		if (local_movement.x > 0.1):
			_turn(0);
		elif (local_movement.x < -0.1):
			_turn(180);
		
		if (local_movement.y < -0.1):
			_facing_back = true;
		elif (local_movement.y > 0.1):
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
		if (override_music):
			MusicManager.change_music(music);
		else:
			MusicManager.change_music(Global.current_level_controller.battle_music);
		
		Global.current_level_controller.battle.start_battle(body.party, enemies_instanced);
	# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("battle_start", self, "_battle_start");
# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("battle_start_early", self, "_battle_start_early");
	# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("battle_end", self, "_battle_end");
# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("battle_end_early", self, "_battle_end_early");
# warning-ignore:return_value_discarded
		Global.current_level_controller.battle.connect("turn_ended", self, "_turn_ended");
		

func _battle_start():
	emit_signal("battle_start");

func _battle_start_early():
	emit_signal("battle_start_early");

func _battle_end():
	emit_signal("battle_end");
	_kill();

func _battle_end_early():
	emit_signal("battle_end_early");
	Global.coin_counter.add_money(reward_money);
	hide();

func _turn_ended(turn_number : int):
	emit_signal("turn_ended", turn_number);
	print("Turn " + str(turn_number) + " has ended");

func _kill():
	queue_free();

func _notification(what : int):
	if (what == NOTIFICATION_PREDELETE):
		for enemy in enemies_instanced:
			if (is_instance_valid(enemy)):
				enemy.queue_free();
