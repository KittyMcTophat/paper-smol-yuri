extends BattleActor

class_name BattlePlayer

export var personal_jump_input : String = "jump";
export var vertical_lerp_weight : float = 3.0;

onready var ground_detector : Area = $GroundDetector;

func _physics_process(delta):
	var grounded : bool = false;
	if (ground_detector.get_overlapping_bodies().size() > 0):
		grounded = true;
	
	if ((Input.is_action_just_pressed("jump") || Input.is_action_just_pressed(personal_jump_input)) && grounded):
		_jump();
	
	if (!is_on_floor()):
		if (!(Input.is_action_pressed("jump") || Input.is_action_pressed(personal_jump_input))):
			if (velocity.y > 0.0):
				velocity.y = lerp(velocity.y, 0.0, delta * vertical_lerp_weight);

func _do_your_turn():
	yield(get_tree().create_timer(0.5), "timeout");
	
	_end_turn();

func _end_turn():
	emit_signal("turn_over");
