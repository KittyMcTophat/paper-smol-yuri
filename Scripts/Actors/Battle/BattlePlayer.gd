extends BattleActor

class_name BattlePlayer

export var personal_jump_input : String = "jump";
export var vertical_lerp_weight : float = 3.0;

onready var ground_detector : Area = $GroundDetector;
onready var action_selector : Spatial = $PlayerActionSelector;

var enable_jump : bool = true;

func _physics_process(delta):
	var grounded : bool = false;
	if (ground_detector.get_overlapping_bodies().size() > 0):
		grounded = true;
	
	if (Input.is_action_just_pressed(personal_jump_input) && grounded && enable_jump):
		_jump();
	
	if (!is_on_floor()):
		if (!Input.is_action_pressed(personal_jump_input)):
			if (velocity.y > 0.0):
				velocity.y = lerp(velocity.y, 0.0, delta * vertical_lerp_weight);

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
