extends KinematicBody

export var velocity : float = 1.5;
export var wait_time : float = 1.0;
export(Array, Vector3) var target_points : Array = [Vector3.ZERO];

var _next_point = 0;
var _stopped = false;

onready var _timer = $Timer;

func _ready():
	_timer.wait_time = wait_time;

func _physics_process(_delta):
	if (!is_visible_in_tree()):
		return;
	
	if (_stopped):
		return;
	
	var vector_to_next_point : Vector3 = calc_vector_to_next_point();
	
	if (vector_to_next_point.length() < 0.05):
		_next_point += 1;
		
		if (_next_point >= target_points.size()):
			_next_point = 0;
		
		_timer.start();
		_stopped = true;
	
	vector_to_next_point = vector_to_next_point.normalized();
#warning-ignore:RETURN_VALUE_DISCARDED
	move_and_slide(vector_to_next_point * velocity);

func calc_vector_to_next_point() -> Vector3:
	return target_points[_next_point] - transform.origin;

func _on_Timer_timeout():
	_stopped = false;
