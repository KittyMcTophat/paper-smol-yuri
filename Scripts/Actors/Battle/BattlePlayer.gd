extends BattleActor

class_name BattlePlayer

export var personal_jump_input : String = "jump";
export var vertical_lerp_weight : float = 3.0;
export var jump_buffer_time : float = 0.2;

onready var action_selector : Spatial = $PlayerActionSelector;

var enable_jump : bool = true;
var _jump_buffer : float = 0.0;

func _ready():
# warning-ignore:return_value_discarded
	self.connect("landed", self, "_check_jump_buffer");

func _enter_battle():
	show();
	do_movement = true;
	
	._enter_battle();

func _physics_process(delta : float):
	if do_movement == false:
		return;
	
	var do_a_jump : bool = Input.is_action_just_pressed(personal_jump_input) || Input.is_action_just_pressed("jump");
	var holding_jump : bool = Input.is_action_pressed(personal_jump_input) || Input.is_action_pressed("jump");
	
	if (do_a_jump && enable_jump):
		if (is_on_floor()):
			_jump();
		else:
			_jump_buffer = jump_buffer_time;
	
	if (!is_on_floor()):
		if (!holding_jump):
			if (velocity.y > 0.0):
				velocity.y = lerp(velocity.y, 0.0, delta * vertical_lerp_weight);
	
	if (_jump_buffer > 0.0):
		_jump_buffer -= delta;

func _check_jump_buffer():
	if (is_on_floor() && _jump_buffer > 0.0):
		_jump();
		_jump_buffer = 0.0;

func _do_your_turn():
	action_selector._pick_action();
	yield(action_selector, "turn_over");
	
	_end_turn();

func _end_turn():
	emit_signal("turn_over");

func _shoot():
	_fire_projectile(default_projectile, target_direction, attack);

func _jump_shoot():
	_jump_and_fire_projectile(jump_strength, default_projectile, target_direction, attack);

func _kill():
	if (is_inside_tree() == false):
		return;
	
	_healthbar.hide();
	
	if Global.current_level_controller.battle.all_players_dead():
		MusicManager.change_music(null);
	
# warning-ignore:return_value_discarded
	var rigidbody : RigidBody = get_fuckin_launched();
	
	_healthbar.show();
	$Death.play();
	
	var store_collision_layer : int = collision_layer;
	var store_collision_mask : int = collision_mask;
	collision_layer = 0;
	collision_mask = 0;
	do_movement = false;
	
	yield(get_tree().create_timer(3.0, false), "timeout");
	
	rigidbody.queue_free();
	
	if Global.current_level_controller.battle.all_players_dead():
		Global.reload_scene();
	else:
		yield(Global.current_level_controller.battle, "battle_end_early");
		collision_layer = store_collision_layer;
		collision_mask = store_collision_mask;
		current_health = 1;
		_healthbar._update_health(current_health, false);
