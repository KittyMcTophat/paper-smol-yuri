extends KinematicBody

export var spring_force : float = 15.0;
onready var _tween_node : Tween = $Tween;

func _on_Area_body_entered(body):
	if "_velocity" in body:
		body._velocity.y = spring_force;
	elif "velocity" in body:
		body.velocity.y = spring_force;
	else:
		return;
	
	$Boing.play();
# warning-ignore:return_value_discarded
	_tween_node.interpolate_property($Pivot, "scale", Vector3(1.2, 0.8, 1.2), Vector3(1.0, 1.0, 1.0), 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT);
# warning-ignore:return_value_discarded
	_tween_node.start();
