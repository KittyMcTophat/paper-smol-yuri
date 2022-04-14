extends StaticBody

class_name MovingPlatform

export var velocity : float = 1.5;
export var wait_time : float = 1.0;
export(Array, Vector3) var target_points : Array = [Vector3.ZERO];

var _next_point = 0;
var _stopped = false;

onready var _timer = $Timer;

func _ready():
	_timer.wait_time = wait_time;

func _physics_process(_delta):
	if (_stopped):
		return;
	
	var vector_to_next_point : Vector3 = calc_vector_to_next_point();
	
	if (vector_to_next_point.length() < 0.02):
		_next_point += 1;
		_next_point = _next_point % target_points.size();
		
		_timer.start();
		_stopped = true;
		constant_linear_velocity = Vector3.ZERO;
		return;
	
#warning-ignore:RETURN_VALUE_DISCARDED
	constant_linear_velocity = vector_to_next_point.normalized() * velocity;
	transform.origin += constant_linear_velocity * _delta;

func calc_vector_to_next_point() -> Vector3:
	return target_points[_next_point] - transform.origin;

func _on_Timer_timeout():
	_stopped = false;
