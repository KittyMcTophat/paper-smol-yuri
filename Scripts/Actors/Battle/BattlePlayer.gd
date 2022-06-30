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

func _physics_process(delta : float):
	if (Input.is_action_just_pressed(personal_jump_input) && enable_jump):
		if (is_on_floor()):
			_jump();
		else:
			_jump_buffer = jump_buffer_time;
	
	if (!is_on_floor()):
		if (!Input.is_action_pressed(personal_jump_input)):
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
	
	MusicManager.change_music(null);
	$Death.play();

# warning-ignore:return_value_discarded
	get_fuckin_launched();
	
	yield(get_tree().create_timer(3.0, false), "timeout");
	
	Global.reload_scene();
